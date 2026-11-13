//
//  DataExporter.swift
//  networt
//

import Foundation
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

/// A generated export file for `ShareLink`.
struct ExportFile: Transferable {
    var data: Data
    var filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { $0.data }
            .suggestedFileName { $0.filename }
    }
}

/// Everything in the store, in a stable format that `Backup.restore` can read back.
struct Backup: Codable, Equatable {
    static let currentVersion = 1

    struct Txn: Codable, Equatable { var date: Date; var operation: String; var value: Double; var currency: String }
    struct Bank: Codable, Equatable { var name: String; var number: Int; var currency: String; var balance: Double; var transactions: [Txn] }
    struct CashItem: Codable, Equatable { var label: String; var amount: Double; var currency: String }
    struct StockItem: Codable, Equatable {
        var symbol: String; var name: String; var sector: String; var exchange: String
        var quantity: Int; var price: Double; var currency: String; var costBasis: Double?; var priceUpdatedAt: Date?
    }
    struct CryptoItem: Codable, Equatable { var coinID: String; var symbol: String; var name: String; var price: Double; var amount: Double; var costBasis: Double? }
    struct Income: Codable, Equatable { var date: Date; var amount: Double; var currency: String; var notes: String? }
    struct PropertyItem: Codable, Equatable {
        var name: String; var currency: String; var purchasePrice: Double; var marketValue: Double; var appreciationPercent: Double
        var latitude: Double?; var longitude: Double?; var rentalIncomes: [Income]
    }
    struct PaymentItem: Codable, Equatable { var date: Date; var amount: Double; var currency: String; var note: String? }
    struct LiabilityItem: Codable, Equatable {
        var name: String; var type: String; var currency: String; var balance: Double
        var creditLimit: Double?; var minPayment: Double?; var interestRate: Double?; var dueDate: Date?; var payments: [PaymentItem]
    }
    struct Snapshot: Codable, Equatable { var date: Date; var currency: String; var assets: Double; var liabilities: Double; var netWorth: Double }

    var version = Backup.currentVersion
    var exportedAt: Date
    var baseCurrency: String
    var banks: [Bank]
    var cash: [CashItem]
    var stocks: [StockItem]
    var crypto: [CryptoItem]
    var properties: [PropertyItem]
    var liabilities: [LiabilityItem]
    var history: [Snapshot]

    enum RestoreError: LocalizedError {
        case unreadable, newerVersion(Int)

        var errorDescription: String? {
            switch self {
            case .unreadable: "This file isn't a networt backup."
            case .newerVersion(let version): "This backup was made by a newer version of the app (format \(version)). Update the app and try again."
            }
        }
    }

    var itemCount: Int {
        banks.count + cash.count + stocks.count + crypto.count + properties.count + liabilities.count
    }

    // MARK: - Export

    @MainActor
    init(context: ModelContext, baseCurrency: String, now: Date = .now) {
        func all<T: PersistentModel>(_ type: T.Type) -> [T] { (try? context.fetch(FetchDescriptor<T>())) ?? [] }

        self.exportedAt = now
        self.baseCurrency = baseCurrency
        banks = all(BankInfo.self).sorted { ($0.bankName, $0.number) < ($1.bankName, $1.number) }.map { bank in
            Bank(name: bank.bankName, number: bank.number, currency: bank.currency, balance: bank.balance,
                 transactions: (bank.transactions ?? []).sorted { $0.dateTime < $1.dateTime }.map { Txn(date: $0.dateTime, operation: $0.operation, value: $0.value, currency: $0.currency) })
        }
        cash = all(Cash.self).sorted { ($0.label, $0.amount) < ($1.label, $1.amount) }.map { CashItem(label: $0.label, amount: $0.amount, currency: $0.currency) }
        stocks = all(Stock.self).sorted { ($0.symbol, $0.quantity) < ($1.symbol, $1.quantity) }.map {
            StockItem(symbol: $0.symbol, name: $0.name, sector: $0.sector, exchange: $0.exchange, quantity: $0.quantity,
                      price: $0.price, currency: $0.currency, costBasis: $0.costBasis, priceUpdatedAt: $0.priceUpdatedAt)
        }
        crypto = all(CoinHolding.self).sorted { ($0.coin?.id ?? "", $0.amount) < ($1.coin?.id ?? "", $1.amount) }.map {
            CryptoItem(coinID: $0.coin?.id ?? "", symbol: $0.coin?.symbol ?? "", name: $0.name, price: $0.price, amount: $0.amount, costBasis: $0.costBasis)
        }
        properties = all(Property.self).sorted { $0.name < $1.name }.map { property in
            PropertyItem(name: property.name, currency: property.currency, purchasePrice: property.purchasePrice, marketValue: property.marketValue,
                         appreciationPercent: property.appreciationPercent, latitude: property.latitude, longitude: property.longitude,
                         rentalIncomes: (property.rentalIncomes ?? []).sorted { $0.date < $1.date }.map { Income(date: $0.date, amount: $0.amount, currency: $0.currency, notes: $0.notes) })
        }
        liabilities = all(Liability.self).sorted { $0.name < $1.name }.map { liability in
            LiabilityItem(name: liability.name, type: liability.type.rawValue, currency: liability.currency, balance: liability.balance,
                          creditLimit: liability.creditLimit, minPayment: liability.minPayment, interestRate: liability.interestRate, dueDate: liability.dueDate,
                          payments: liability.paymentHistory.reversed().map { PaymentItem(date: $0.date, amount: $0.amount, currency: $0.currency, note: $0.note) })
        }
        history = all(NetWorthSnapshot.self).sorted { $0.date < $1.date }.map {
            Snapshot(date: $0.date, currency: $0.currency, assets: $0.assets, liabilities: $0.liabilities, netWorth: $0.netWorth)
        }
    }

    func encoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return (try? encoder.encode(self)) ?? Data()
    }

    // MARK: - Restore

    static func decode(_ data: Data) throws -> Backup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        struct Header: Decodable { var version: Int }
        guard let header = try? decoder.decode(Header.self, from: data) else { throw RestoreError.unreadable }
        guard header.version <= currentVersion else { throw RestoreError.newerVersion(header.version) }
        guard let backup = try? decoder.decode(Backup.self, from: data) else { throw RestoreError.unreadable }
        return backup
    }

    /// Replaces everything in `context` with this backup's contents.
    @MainActor
    func restore(into context: ModelContext) throws {
        try context.delete(model: Transaction.self)
        try context.delete(model: BankInfo.self)
        try context.delete(model: Cash.self)
        try context.delete(model: Stock.self)
        try context.delete(model: CoinHolding.self)
        try context.delete(model: Coin.self)
        try context.delete(model: Payment.self)
        try context.delete(model: Liability.self)
        try context.delete(model: RentalIncome.self)
        try context.delete(model: Property.self)
        try context.delete(model: NetWorthSnapshot.self)

        for item in banks {
            let bank = BankInfo(balance: item.balance, bankName: item.name, currency: item.currency, number: item.number)
            context.insert(bank)
            for txn in item.transactions {
                context.insert(Transaction(dateTime: txn.date, operation: txn.operation, value: txn.value, currency: txn.currency, bankInfo: bank))
            }
        }
        for item in cash {
            context.insert(Cash(amount: item.amount, currency: item.currency, label: item.label))
        }
        for item in stocks {
            let stock = Stock(symbol: item.symbol, name: item.name, sector: item.sector, exchange: item.exchange)
            stock.quantity = item.quantity
            stock.price = item.price
            stock.currency = item.currency
            stock.costBasis = item.costBasis
            stock.priceUpdatedAt = item.priceUpdatedAt
            context.insert(stock)
        }
        var coins: [String: Coin] = [:]
        for item in crypto {
            let coin = coins[item.coinID] ?? Coin(id: item.coinID, symbol: item.symbol, name: item.name, current_price: item.price)
            coins[item.coinID] = coin
            let holding = CoinHolding(coin: coin, amount: item.amount)
            holding.costBasis = item.costBasis
            context.insert(holding)
        }
        for item in properties {
            let property = Property(name: item.name, currency: item.currency, purchasePrice: item.purchasePrice, marketValue: item.marketValue, appreciationPercent: item.appreciationPercent)
            property.latitude = item.latitude
            property.longitude = item.longitude
            context.insert(property)
            property.rentalIncomes = item.rentalIncomes.map { RentalIncome(date: $0.date, amount: $0.amount, currency: $0.currency, notes: $0.notes) }
        }
        for item in liabilities {
            let liability = Liability(name: item.name, type: LiabilityType(rawValue: item.type) ?? .loan, currency: item.currency, balance: item.balance,
                                      creditLimit: item.creditLimit, minPayment: item.minPayment, interestRate: item.interestRate, dueDate: item.dueDate)
            context.insert(liability)
            liability.payments = item.payments.map { Payment(currency: $0.currency, amount: $0.amount, date: $0.date, note: $0.note) }
        }
        for item in history {
            context.insert(NetWorthSnapshot(date: item.date, currency: item.currency, assets: item.assets, liabilities: item.liabilities, netWorth: item.netWorth))
        }
        try context.save()
    }
}

@MainActor
struct DataExporter {
    var context: ModelContext
    var calculator: NetWorthCalculator

    private func all<T: PersistentModel>(_ type: T.Type) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }

    private struct Row {
        var category: NetWorthCategory
        var name: String
        var currency: String
        var amount: Double
    }

    private var rows: [Row] {
        all(BankInfo.self).map { Row(category: .bank, name: $0.bankName, currency: $0.currency, amount: $0.balance) }
            + all(Cash.self).map { Row(category: .cash, name: $0.displayName, currency: $0.currency, amount: $0.amount) }
            + all(Stock.self).map { Row(category: .stocks, name: "\($0.symbol) × \($0.quantity)", currency: $0.currency, amount: $0.marketValue) }
            + all(CoinHolding.self).map { Row(category: .crypto, name: "\($0.symbol) × \($0.amount)", currency: "USD", amount: $0.totalValue) }
            + all(Property.self).map { Row(category: .realEstate, name: $0.name, currency: $0.currency, amount: $0.marketValue) }
            + all(Liability.self).map { Row(category: .liabilities, name: $0.name, currency: $0.currency, amount: -abs($0.balance)) }
    }

    func csv() -> ExportFile {
        let base = calculator.baseCurrency.uppercased()
        var lines = ["Category,Name,Currency,Amount,Value (\(base))"]
        for row in rows {
            let converted = calculator.convert(row.amount, from: row.currency).map { String(format: "%.2f", $0) } ?? ""
            lines.append([row.category.rawValue, row.name, row.currency.uppercased(), String(format: "%.2f", row.amount), converted].map(Self.escape).joined(separator: ","))
        }
        return ExportFile(data: Data(lines.joined(separator: "\n").utf8), filename: "networth-\(Self.stamp).csv")
    }

    func backup() -> ExportFile {
        ExportFile(data: Backup(context: context, baseCurrency: calculator.baseCurrency).encoded(), filename: "networth-backup-\(Self.stamp).json")
    }

    private static var stamp: String {
        Date.now.formatted(.iso8601.year().month().day())
    }

    private static func escape(_ field: String) -> String {
        field.contains(where: { ",\"\n".contains($0) }) ? "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\"" : field
    }
}
