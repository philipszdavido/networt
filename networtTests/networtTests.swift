//
//  networtTests.swift
//  networtTests
//
//  Created by Chidume Nnamdi on 4/3/24.
//

import XCTest
import SwiftData
@testable import networt

/// EUR-based rates, as the fawazahmed0 API returns them.
private let rates = CurrencyRatesFawazahmed0(date: "2026-11-12", data: ["eur": 1, "usd": 1.1, "ngn": 1650, "gbp": 0.85], type: "eur")

final class CurrencyConversionTests: XCTestCase {

    func testConvertsThroughTheBaseCurrency() {
        let result = CurrencyRates.convertCurrency(amount: 110, from: "USD", to: "EUR", using: rates)
        XCTAssertEqual(result!, 100, accuracy: 0.0001)

        let crossRate = CurrencyRates.convertCurrency(amount: 11, from: "usd", to: "ngn", using: rates)
        XCTAssertEqual(crossRate!, 16500, accuracy: 0.0001)
    }

    func testUnknownCurrencyReturnsNil() {
        XCTAssertNil(CurrencyRates.convertCurrency(amount: 1, from: "XYZ", to: "EUR", using: rates))
    }

    func testFetchRatesUsesInjectedLoader() async throws {
        let json = #"{"date":"2026-11-12","eur":{"usd":1.1,"eur":1}}"#
        let result = try await CurrencyRates.fetchCurrencyRates(load: { _ in Data(json.utf8) })
        XCTAssertEqual(result.date, "2026-11-12")
        XCTAssertEqual(result.data["usd"], 1.1)
        XCTAssertEqual(result.type, "eur")
    }
}

final class NetWorthCalculatorTests: XCTestCase {

    let calculator = NetWorthCalculator(baseCurrency: "USD", rates: rates)

    func testSumsEveryCategoryAndSubtractsLiabilities() {
        let stock = Stock(symbol: "AAPL", name: "Apple", sector: "Tech", exchange: "NASDAQ")
        stock.quantity = 2
        stock.price = 50

        let breakdown = calculator.breakdown(
            bankInfos: [BankInfo(balance: 100.5, bankName: "A", currency: "USD", number: 1)],
            cash: [Cash(amount: 100, currency: "EUR")],
            stocks: [stock],
            coinHoldings: [CoinHolding(coin: Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", current_price: 1000), amount: 0.5)],
            properties: [Property(name: "Flat", currency: "USD", purchasePrice: 1, marketValue: 1000, appreciationPercent: 0)],
            liabilities: [Liability(name: "Card", type: .creditCard, currency: "USD", balance: 200)]
        )

        XCTAssertEqual(breakdown[.bank], 100.5, accuracy: 0.0001)
        XCTAssertEqual(breakdown[.cash], 110, accuracy: 0.0001)
        XCTAssertEqual(breakdown[.stocks], 100, accuracy: 0.0001)
        XCTAssertEqual(breakdown[.crypto], 500, accuracy: 0.0001)
        XCTAssertEqual(breakdown[.realEstate], 1000, accuracy: 0.0001)
        XCTAssertEqual(breakdown.assets, 1810.5, accuracy: 0.0001)
        XCTAssertEqual(breakdown.liabilities, 200, accuracy: 0.0001)
        XCTAssertEqual(breakdown.netWorth, 1610.5, accuracy: 0.0001)
        XCTAssertEqual(breakdown.allocation(of: .realEstate), 1000 / 1810.5, accuracy: 0.0001)
        XCTAssertTrue(breakdown.unconvertibleCurrencies.isEmpty)
    }

    func testReportsCurrenciesWithoutARateInsteadOfCountingZero() {
        let breakdown = calculator.breakdown(
            bankInfos: [
                BankInfo(balance: 10, bankName: "A", currency: "USD", number: 1),
                BankInfo(balance: 999, bankName: "B", currency: "xyz", number: 2),
            ]
        )
        XCTAssertEqual(breakdown[.bank], 10)
        XCTAssertEqual(breakdown.unconvertibleCurrencies, ["XYZ"])
    }

    func testBaseCurrencyNeedsNoRate() {
        let calculator = NetWorthCalculator(baseCurrency: "ABC", rates: CurrencyRates.getEmptyCurrencyRatesFawazahmed0())
        XCTAssertEqual(calculator.convert(42, from: "abc"), 42)
    }
}

final class DebtPlannerTests: XCTestCase {

    func testZeroInterestPaysOffInBalanceOverPayment() {
        let plan = DebtPlanner.plan([.init(name: "A", balance: 1000, apr: 0, minPayment: 100)], extra: 0, strategy: .avalanche)
        XCTAssertEqual(plan.months, 10)
        XCTAssertEqual(plan.totalInterest, 0)
    }

    func testStrategiesPickDifferentFirstTargets() {
        let debts: [DebtPlanner.Debt] = [
            .init(name: "Small, cheap", balance: 2000, apr: 5, minPayment: 50),
            .init(name: "Big, expensive", balance: 3000, apr: 25, minPayment: 60),
        ]
        let snowball = DebtPlanner.plan(debts, extra: 500, strategy: .snowball)
        let avalanche = DebtPlanner.plan(debts, extra: 500, strategy: .avalanche)

        XCTAssertEqual(snowball.payoffOrder.first?.name, "Small, cheap")
        XCTAssertEqual(avalanche.payoffOrder.first?.name, "Big, expensive")
        XCTAssertLessThan(avalanche.totalInterest, snowball.totalInterest)
    }

    func testPaymentsBelowInterestNeverFinish() {
        let plan = DebtPlanner.plan([.init(name: "A", balance: 10000, apr: 24, minPayment: 100)], extra: 0, strategy: .avalanche)
        XCTAssertNil(plan.months)
    }
}

final class LockStoreTests: XCTestCase {

    let store = LockStore(service: "networtTests.lock")

    override func tearDown() {
        store.clear()
    }

    func testVerifiesOnlyTheSavedPin() {
        XCTAssertFalse(store.hasPasscode)
        store.setPasscode("1234")
        XCTAssertTrue(store.hasPasscode)
        XCTAssertTrue(store.verify("1234"))
        XCTAssertFalse(store.verify("4321"))
    }

    func testClearRemovesThePin() {
        store.setPasscode("1234")
        store.clear()
        XCTAssertFalse(store.hasPasscode)
        XCTAssertFalse(store.verify("1234"))
    }

    func testMigratesAndDeletesPlaintextPin() {
        let defaults = UserDefaults(suiteName: "networtTests")!
        defaults.removePersistentDomain(forName: "networtTests")
        defaults.set("9876", forKey: "lockCodes")
        defaults.set(true, forKey: "isLockCodeSet")

        store.migrateLegacyPasscode(from: defaults)

        XCTAssertTrue(store.verify("9876"))
        XCTAssertNil(defaults.string(forKey: "lockCodes"))
        XCTAssertNil(defaults.object(forKey: "isLockCodeSet"))
    }
}

final class PriceTests: XCTestCase {

    func testYahooQuoteParsingAndMinorUnits() async throws {
        let json = #"{"chart":{"result":[{"meta":{"regularMarketPrice":1234.5,"currency":"GBp"}}],"error":null}}"#
        let provider = YahooQuoteProvider(load: { url in
            XCTAssertTrue(url.absoluteString.contains("/chart/HSBA.L"))
            return Data(json.utf8)
        })
        let quote = try await provider.quote(symbol: "HSBA.L")
        XCTAssertEqual(quote.currency, "GBP")
        XCTAssertEqual(quote.price, 12.345, accuracy: 0.0001)
    }

    func testCoinGeckoPricesById() async throws {
        let json = #"[{"id":"bitcoin","symbol":"btc","current_price":50000},{"id":"ethereum","symbol":"eth","current_price":3000}]"#
        let prices = try await CoinGeckoPrices(load: { url in
            XCTAssertTrue(url.query!.contains("ids=bitcoin,ethereum"))
            return Data(json.utf8)
        }).prices(ids: ["bitcoin", "ethereum"])
        XCTAssertEqual(prices, ["bitcoin": 50000, "ethereum": 3000])
    }

    func testGainUsesCostBasis() {
        let stock = Stock(symbol: "A", name: "A", sector: "", exchange: "")
        stock.quantity = 10
        stock.price = 12
        XCTAssertNil(stock.unrealizedGain)
        stock.costBasis = 10
        XCTAssertEqual(stock.unrealizedGain, 20)
    }
}

final class ReminderTests: XCTestCase {

    func testRemindsThreeDaysEarlyThenOnTheDay() {
        let calendar = Calendar.current
        let due = calendar.date(from: DateComponents(year: 2026, month: 12, day: 20, hour: 15))!

        let early = Reminders.reminderDate(for: due, now: calendar.date(from: DateComponents(year: 2026, month: 12, day: 1))!)
        XCTAssertEqual(early, calendar.date(from: DateComponents(year: 2026, month: 12, day: 17, hour: 9)))

        let sameDay = Reminders.reminderDate(for: due, now: calendar.date(from: DateComponents(year: 2026, month: 12, day: 19))!)
        XCTAssertEqual(sameDay, calendar.date(from: DateComponents(year: 2026, month: 12, day: 20, hour: 9)))

        XCTAssertNil(Reminders.reminderDate(for: due, now: calendar.date(from: DateComponents(year: 2026, month: 12, day: 21))!))
    }
}

final class ParsingTests: XCTestCase {

    func testParsesDecimalInput() {
        XCTAssertEqual(Double.parse("12.5"), 12.5)
        XCTAssertEqual(Double.parse(" 400 "), 400)
        XCTAssertNil(Double.parse(""))
        XCTAssertNil(Double.parse("abc"))
    }
}

@MainActor
final class PersistenceTests: XCTestCase {

    func makeContext() throws -> ModelContext {
        let container = try ModelContainer(for: Schema(allModels), configurations: [ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)])
        return ModelContext(container)
    }

    func testSnapshotIsOnePerDay() throws {
        let context = try makeContext()
        var breakdown = NetWorthBreakdown(totals: [.bank: 100])
        let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
        let evening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now)!

        NetWorthSnapshot.record(breakdown, currency: "USD", in: context, now: morning)
        breakdown.totals[.bank] = 150
        NetWorthSnapshot.record(breakdown, currency: "USD", in: context, now: evening)

        let snapshots = try context.fetch(FetchDescriptor<NetWorthSnapshot>())
        XCTAssertEqual(snapshots.count, 1)
        XCTAssertEqual(snapshots.first?.netWorth, 150)
    }

    func testLegacyIntAmountsMoveIntoBalance() throws {
        let context = try makeContext()
        let bank = BankInfo(balance: 0, bankName: "Old", currency: "USD", number: 1)
        bank.legacyAmount = 700
        let txn = Transaction(dateTime: .now, operation: "+", value: 0, currency: "USD")
        txn.legacyAmount = 50
        context.insert(bank)
        context.insert(txn)

        LegacyMigration.run(context)

        XCTAssertEqual(bank.balance, 700)
        XCTAssertEqual(bank.legacyAmount, 0)
        XCTAssertEqual(txn.value, 50)
    }

    func testDeletingABankDeletesItsTransactions() throws {
        let context = try makeContext()
        let bank = BankInfo(balance: 0, bankName: "A", currency: "USD", number: 1)
        context.insert(bank)
        context.insert(Transaction(dateTime: .now, operation: "+", value: 5, currency: "USD", bankInfo: bank))
        try context.save()

        context.delete(bank)
        try context.save()

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Transaction>()), 0)
    }

    func testSyncedDuplicateSnapshotsCollapseToOne() throws {
        let context = try makeContext()
        let day = Calendar.current.startOfDay(for: .now)
        context.insert(NetWorthSnapshot(date: day, currency: "USD", assets: 1, liabilities: 0, netWorth: 1))
        context.insert(NetWorthSnapshot(date: day, currency: "USD", assets: 2, liabilities: 0, netWorth: 2))

        NetWorthSnapshot.record(NetWorthBreakdown(totals: [.cash: 5]), currency: "USD", in: context)

        let snapshots = try context.fetch(FetchDescriptor<NetWorthSnapshot>())
        XCTAssertEqual(snapshots.count, 1)
        XCTAssertEqual(snapshots.first?.netWorth, 5)
    }

    func testBackupRoundTripsEveryField() throws {
        let source = try makeContext()
        let bank = BankInfo(balance: 1200.5, bankName: "UBA", currency: "NGN", number: 123456)
        source.insert(bank)
        source.insert(Transaction(dateTime: Date(timeIntervalSince1970: 1_700_000_000), operation: "-", value: 20, currency: "NGN", bankInfo: bank))
        source.insert(Cash(amount: 40, currency: "USD", label: "Wallet"))
        let stock = Stock(symbol: "AAPL", name: "Apple", sector: "Tech", exchange: "NASDAQ")
        stock.quantity = 3; stock.price = 200; stock.costBasis = 150
        source.insert(stock)
        let coin = Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", current_price: 50000)
        source.insert(CoinHolding(coin: coin, amount: 0.25))
        source.insert(CoinHolding(coin: coin, amount: 0.75))
        let property = Property(name: "Flat", currency: "EUR", purchasePrice: 100, marketValue: 150, appreciationPercent: 3)
        source.insert(property)
        property.rentalIncomes = [RentalIncome(date: Date(timeIntervalSince1970: 1_700_000_000), amount: 10, currency: "EUR", notes: "Jan")]
        let card = Liability(name: "Visa", type: .creditCard, currency: "USD", balance: 900, creditLimit: 2000, minPayment: 25, interestRate: 19.9)
        source.insert(card)
        card.payments = [Payment(currency: "USD", amount: 50, date: Date(timeIntervalSince1970: 1_700_000_000), note: "Min")]
        source.insert(NetWorthSnapshot(date: Date(timeIntervalSince1970: 1_700_000_000), currency: "USD", assets: 10, liabilities: 2, netWorth: 8))
        try source.save()

        let backup = Backup(context: source, baseCurrency: "USD", now: Date(timeIntervalSince1970: 1_800_000_000))
        let decoded = try Backup.decode(backup.encoded())
        XCTAssertEqual(decoded, backup)

        // Restoring replaces whatever was there.
        let target = try makeContext()
        target.insert(Cash(amount: 999, currency: "USD", label: "Old"))
        try decoded.restore(into: target)

        let again = Backup(context: target, baseCurrency: "USD", now: backup.exportedAt)
        XCTAssertEqual(again, backup)
        XCTAssertEqual(try target.fetchCount(FetchDescriptor<Coin>()), 1, "holdings of the same coin share one Coin")
        XCTAssertEqual(try target.fetchCount(FetchDescriptor<Cash>()), 1)
    }

    func testRestoreRejectsOtherFilesAndNewerVersions() {
        XCTAssertThrowsError(try Backup.decode(Data("{\"hello\":1}".utf8)))
        XCTAssertThrowsError(try Backup.decode(Data("{\"version\":99}".utf8))) { error in
            guard case Backup.RestoreError.newerVersion(99) = error else { return XCTFail("\(error)") }
        }
    }
}

final class WidgetTests: XCTestCase {

    func testSnapshotIncludesTodayAndMonthChange() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let day: (Int) -> Date = { Calendar.current.date(byAdding: .day, value: -$0, to: now)! }
        let history = [
            HistoryPoint(date: day(120), assets: 50, liabilities: 0),
            HistoryPoint(date: day(40), assets: 100, liabilities: 0),
            HistoryPoint(date: day(5), assets: 140, liabilities: 0),
        ]

        let snapshot = WidgetBridge.make(netWorth: 150, currency: "USD", history: history, hidden: false, now: now)

        XCTAssertEqual(snapshot.points.map(\.value), [100, 140, 150], "drops points older than 90 days, appends today")
        XCTAssertEqual(snapshot.monthChange, 50)
        XCTAssertEqual(snapshot.monthChangePercent!, 0.5, accuracy: 0.0001)
    }

    func testSnapshotFileRoundTrip() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("widget-\(UUID()).json")
        defer { try? FileManager.default.removeItem(at: url) }

        var snapshot = WidgetSnapshot.placeholder
        snapshot.updatedAt = Date(timeIntervalSince1970: 1_800_000_000)
        snapshot.points = snapshot.points.map { .init(date: Date(timeIntervalSince1970: $0.date.timeIntervalSince1970.rounded()), value: $0.value) }
        XCTAssertTrue(snapshot.save(to: url))
        XCTAssertEqual(WidgetSnapshot.load(from: url), snapshot)
    }

    func testHistoryKeepsOnePointPerDay() {
        let calculator = NetWorthCalculator(baseCurrency: "USD", rates: rates)
        let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
        let evening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now)!
        let history = NetWorthHistory(snapshots: [
            NetWorthSnapshot(date: morning, currency: "USD", assets: 1, liabilities: 0, netWorth: 1),
            NetWorthSnapshot(date: evening, currency: "EUR", assets: 10, liabilities: 0, netWorth: 10),
        ], calculator: calculator)
        XCTAssertEqual(history.points.count, 1)
    }
}
