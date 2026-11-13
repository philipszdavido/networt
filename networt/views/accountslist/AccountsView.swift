//
//  AccountsView.swift
//  networt
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    var body: some View {
        NavigationStack {
            AccountsList(filter: nil)
        }
    }
}

/// Every holding grouped by category, or a single category when `filter` is set.
struct AccountsList: View {
    var filter: NetWorthCategory?

    @Environment(GlobalSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BankInfo.bankName) private var bankInfos: [BankInfo]
    @Query private var cash: [Cash]
    @Query(sort: \Stock.symbol) private var stocks: [Stock]
    @Query private var coinHoldings: [CoinHolding]
    @Query(sort: \Property.name) private var properties: [Property]
    @Query(sort: \Liability.name) private var liabilities: [Liability]

    @State private var search = ""
    @State private var adding: AddableType?
    @State private var editingCash: Cash?

    var calculator: NetWorthCalculator { NetWorthCalculator(settings: settings) }

    func shows(_ category: NetWorthCategory) -> Bool {
        filter == nil || filter == category
    }

    func matches(_ texts: String...) -> Bool {
        search.isEmpty || texts.contains { $0.localizedStandardContains(search) }
    }

    var body: some View {
        let banks = bankInfos.filter { matches($0.bankName) }
        let cash = cash.filter { matches($0.displayName, $0.currency) }
        let stocks = stocks.filter { matches($0.symbol, $0.name) }
        let coins = coinHoldings.filter { matches($0.name, $0.symbol) }.sorted { $0.totalValue > $1.totalValue }
        let properties = properties.filter { matches($0.name) }
        let liabilities = liabilities.filter { matches($0.name) }
        let breakdown = calculator.breakdown(bankInfos: banks, cash: cash, stocks: stocks, coinHoldings: coins, properties: properties, liabilities: liabilities)
        let isEmpty = (shows(.bank) ? banks.count : 0) + (shows(.cash) ? cash.count : 0) + (shows(.stocks) ? stocks.count : 0)
            + (shows(.crypto) ? coins.count : 0) + (shows(.realEstate) ? properties.count : 0) + (shows(.liabilities) ? liabilities.count : 0) == 0

        List {
            if shows(.bank) && !banks.isEmpty {
                section(.bank, breakdown) {
                    ForEach(banks) { bank in
                        NavigationLink { BankAccountDetailView(bank: bank) } label: {
                            HoldingRow(icon: NetWorthCategory.bank.icon, tint: NetWorthCategory.bank.tint, title: bank.bankName,
                                       subtitle: bank.number == 0 ? bank.currency.uppercased() : "•• \(String(bank.number).suffix(4))",
                                       amount: bank.balance, currency: bank.currency)
                        }
                        .swipeActions { delete(bank) }
                    }
                }
            }
            if shows(.cash) && !cash.isEmpty {
                section(.cash, breakdown) {
                    ForEach(cash) { item in
                        Button { editingCash = item } label: {
                            HoldingRow(icon: NetWorthCategory.cash.icon, tint: NetWorthCategory.cash.tint, title: item.displayName,
                                       subtitle: item.currency.uppercased(), amount: item.amount, currency: item.currency)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions { delete(item) }
                    }
                }
            }
            if shows(.stocks) && !stocks.isEmpty {
                section(.stocks, breakdown) {
                    ForEach(stocks) { stock in
                        NavigationLink { StockDetailView(stock: stock) } label: {
                            HoldingRow(icon: NetWorthCategory.stocks.icon, tint: NetWorthCategory.stocks.tint, title: stock.symbol,
                                       subtitle: "\(stock.quantity) shares", amount: stock.marketValue, currency: stock.currency) {
                                if let gain = stock.unrealizedGain { GainText(gain: gain, currency: stock.currency) }
                            }
                        }
                        .swipeActions { delete(stock) }
                    }
                }
            }
            if shows(.crypto) && !coins.isEmpty {
                section(.crypto, breakdown) {
                    ForEach(coins) { holding in
                        NavigationLink { CryptoDetailView(holding: holding) } label: {
                            HoldingRow(icon: NetWorthCategory.crypto.icon, tint: NetWorthCategory.crypto.tint, title: holding.name,
                                       subtitle: "\(holding.amount.formatted(.number.precision(.fractionLength(0...6)))) \(holding.symbol)",
                                       amount: holding.totalValue, currency: "USD") {
                                if let gain = holding.unrealizedGain { GainText(gain: gain, currency: "USD") }
                            }
                        }
                        .swipeActions { delete(holding) }
                    }
                }
            }
            if shows(.realEstate) && !properties.isEmpty {
                section(.realEstate, breakdown) {
                    ForEach(properties) { property in
                        NavigationLink { PropertyDetailView(property: property) } label: {
                            HoldingRow(icon: NetWorthCategory.realEstate.icon, tint: NetWorthCategory.realEstate.tint, title: property.name,
                                       subtitle: property.currency.uppercased(), amount: property.marketValue, currency: property.currency) {
                                GainText(gain: property.gain, currency: property.currency)
                            }
                        }
                        .swipeActions { delete(property) }
                    }
                }
            }
            if shows(.liabilities) && !liabilities.isEmpty {
                section(.liabilities, breakdown) {
                    ForEach(liabilities) { liability in
                        NavigationLink { LiabilityDetailView(liability: liability) } label: {
                            HoldingRow(icon: liability.type == .creditCard ? "creditcard.fill" : "doc.text.fill", tint: NetWorthCategory.liabilities.tint,
                                       title: liability.name, subtitle: liability.dueDate.map { "Due \($0.formatted(.dateTime.day().month()))" } ?? liability.type.rawValue,
                                       amount: -abs(liability.balance), currency: liability.currency)
                        }
                        .swipeActions { delete(liability) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if isEmpty {
                if search.isEmpty {
                    ContentUnavailableView {
                        Label(filter == nil ? "No accounts yet" : "No \(filter!.title.lowercased()) yet", systemImage: filter?.icon ?? "tray")
                    } description: {
                        Text("Add what you own and owe to see your net worth.")
                    } actions: {
                        Button("Add") { adding = addableType ?? .bank }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ContentUnavailableView.search(text: search)
                }
            }
        }
        .searchable(text: $search, prompt: "Search accounts")
        .navigationTitle(filter?.title ?? "Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let addableType {
                    Button { adding = addableType } label: { Image(systemName: "plus").font(.body.weight(.semibold)) }
                        .accessibilityLabel("Add \(addableType.title)")
                } else {
                    AddMenu(adding: $adding)
                }
            }
        }
        .sheet(item: $adding) { AddHoldingSheet(initialType: $0) }
        .sheet(item: $editingCash) { item in
            NavigationStack { CashForm(cash: item) }
        }
    }

    var addableType: AddableType? {
        filter.flatMap { category in AddableType.allCases.first { $0.category == category } }
    }

    func section<Content: View>(_ category: NetWorthCategory, _ breakdown: NetWorthBreakdown, @ViewBuilder content: () -> Content) -> some View {
        Section {
            content()
        } header: {
            HStack {
                Text(category.title)
                Spacer()
                AmountText(category == .liabilities ? -breakdown[category] : breakdown[category], currency: settings.currency)
            }
            .font(.footnote.weight(.semibold))
        }
    }

    func delete(_ model: any PersistentModel) -> some View {
        Button(role: .destructive) {
            withAnimation { modelContext.delete(model) }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    AccountsView()
        .modelContainer(for: allModels, inMemory: true)
        .environment(GlobalSettings())
}
