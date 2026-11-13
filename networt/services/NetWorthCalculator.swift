//
//  NetWorthCalculator.swift
//  networt
//

import Foundation

enum NetWorthCategory: String, CaseIterable, Identifiable {
    case bank = "Bank"
    case cash = "Cash"
    case stocks = "Stocks"
    case crypto = "Crypto"
    case realEstate = "Real Estate"
    case liabilities = "Liabilities"

    var id: String { rawValue }
}

struct NetWorthBreakdown: Equatable {
    var totals: [NetWorthCategory: Double] = [:]
    /// Currencies held somewhere that have no conversion rate. Those holdings are left out of the totals.
    var unconvertibleCurrencies: Set<String> = []

    subscript(category: NetWorthCategory) -> Double {
        totals[category] ?? 0
    }

    var assets: Double {
        NetWorthCategory.allCases
            .filter { $0 != .liabilities }
            .map { self[$0] }
            .reduce(0, +)
    }

    var liabilities: Double { self[.liabilities] }

    var netWorth: Double { assets - liabilities }

    var investments: Double { self[.stocks] + self[.crypto] + self[.realEstate] }

    /// Share of total assets held in `category`, from 0 to 1.
    func allocation(of category: NetWorthCategory) -> Double {
        assets > 0 ? self[category] / assets : 0
    }
}

/// The single place where holdings are converted into the base currency and summed.
struct NetWorthCalculator {
    var baseCurrency: String
    var rates: CurrencyRatesFawazahmed0

    init(baseCurrency: String, rates: CurrencyRatesFawazahmed0) {
        self.baseCurrency = baseCurrency
        self.rates = rates
    }

    init(settings: GlobalSettings) {
        self.init(baseCurrency: settings.currency, rates: settings.currencyRates)
    }

    func breakdown(
        bankInfos: [BankInfo] = [],
        cash: [Cash] = [],
        stocks: [Stock] = [],
        coinHoldings: [CoinHolding] = [],
        properties: [Property] = [],
        liabilities: [Liability] = []
    ) -> NetWorthBreakdown {
        var result = NetWorthBreakdown()

        func add(_ category: NetWorthCategory, _ amount: Double, _ currency: String) {
            if let converted = convert(amount, from: currency) {
                result.totals[category, default: 0] += converted
            } else {
                result.unconvertibleCurrencies.insert(currency.uppercased())
            }
        }

        bankInfos.forEach { add(.bank, $0.balance, $0.currency) }
        cash.forEach { add(.cash, $0.amount, $0.currency) }
        stocks.forEach { add(.stocks, $0.marketValue, $0.currency) }
        coinHoldings.forEach { add(.crypto, $0.totalValue, "USD") }
        properties.forEach { add(.realEstate, $0.marketValue, $0.currency) }
        liabilities.forEach { add(.liabilities, abs($0.balance), $0.currency) }

        return result
    }

    func convert(_ amount: Double, from currency: String) -> Double? {
        if amount == 0 || currency.lowercased() == baseCurrency.lowercased() {
            return amount
        }
        return CurrencyRates.convertCurrency(amount: amount, from: currency, to: baseCurrency, using: rates)
    }
}
