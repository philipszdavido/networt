//
//  PriceRefresher.swift
//  networt
//

import Foundation
import SwiftData

struct StockQuote: Equatable {
    var price: Double
    var currency: String
}

protocol StockQuoteProvider {
    func quote(symbol: String) async throws -> StockQuote
}

/// Yahoo Finance's public chart endpoint. It is unofficial and needs no key, so it can change
/// without notice; swap in another `StockQuoteProvider` if it stops working.
struct YahooQuoteProvider: StockQuoteProvider {
    var load: DataLoader = { url in
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private struct Response: Decodable {
        struct Chart: Decodable { var result: [Result]? }
        struct Result: Decodable { var meta: Meta }
        struct Meta: Decodable {
            var regularMarketPrice: Double
            var currency: String
        }
        var chart: Chart
    }

    func quote(symbol: String) async throws -> StockQuote {
        let encoded = symbol.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? symbol
        guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(encoded)?range=1d&interval=1d") else {
            throw URLError(.badURL)
        }
        let response = try JSONDecoder().decode(Response.self, from: try await load(url))
        guard let meta = response.chart.result?.first?.meta else {
            throw URLError(.cannotParseResponse)
        }
        return Self.normalize(StockQuote(price: meta.regularMarketPrice, currency: meta.currency))
    }

    /// Some exchanges quote in minor units (London in pence, Johannesburg in cents).
    static func normalize(_ quote: StockQuote) -> StockQuote {
        switch quote.currency {
        case "GBp", "GBX": StockQuote(price: quote.price / 100, currency: "GBP")
        case "ZAc", "ZAC": StockQuote(price: quote.price / 100, currency: "ZAR")
        case "ILA": StockQuote(price: quote.price / 100, currency: "ILS")
        default: StockQuote(price: quote.price, currency: quote.currency.uppercased())
        }
    }
}

struct CoinGeckoPrices {
    var load: DataLoader = urlSessionLoader

    private struct CoinPrice: Decodable {
        var id: String
        var current_price: Double
    }

    /// USD prices keyed by CoinGecko coin id.
    func prices(ids: [String]) async throws -> [String: Double] {
        guard !ids.isEmpty else { return [:] }
        var components = URLComponents(string: "https://api.coingecko.com/api/v3/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
        ]
        let decoded = try JSONDecoder().decode([CoinPrice].self, from: try await load(components.url!))
        return Dictionary(decoded.map { ($0.id, $0.current_price) }, uniquingKeysWith: { first, _ in first })
    }
}

/// Updates stored stock and coin prices.
@MainActor
enum PriceRefresher {
    static var stockQuotes: StockQuoteProvider = YahooQuoteProvider()
    static var coinPrices = CoinGeckoPrices()

    static let staleAfter: TimeInterval = 12 * 60 * 60

    /// Returns the number of holdings that could not be refreshed.
    @discardableResult
    static func refreshAll(in context: ModelContext, rates: CurrencyRatesFawazahmed0) async -> Int {
        let stockFailures = await refreshStocks(in: context, rates: rates)
        let coinFailures = await refreshCrypto(in: context)
        try? context.save()
        return stockFailures + coinFailures
    }

    static func refreshIfStale(in context: ModelContext, rates: CurrencyRatesFawazahmed0) async {
        let cutoff = Date.now.addingTimeInterval(-staleAfter)
        let stocks = (try? context.fetch(FetchDescriptor<Stock>())) ?? []
        let coins = (try? context.fetch(FetchDescriptor<Coin>())) ?? []
        let stale = stocks.contains { ($0.priceUpdatedAt ?? .distantPast) < cutoff }
            || coins.contains { ($0.priceUpdatedAt ?? .distantPast) < cutoff }
        if stale {
            await refreshAll(in: context, rates: rates)
        }
    }

    static func refreshStocks(in context: ModelContext, rates: CurrencyRatesFawazahmed0) async -> Int {
        let stocks = (try? context.fetch(FetchDescriptor<Stock>())) ?? []
        var failures = 0

        for (symbol, holdings) in Dictionary(grouping: stocks, by: \.symbol) {
            guard let quote = try? await stockQuotes.quote(symbol: symbol) else {
                failures += holdings.count
                continue
            }
            for stock in holdings {
                // Older versions assumed USD; keep the cost basis in the quote's currency.
                if stock.currency != quote.currency, let costBasis = stock.costBasis,
                   let converted = CurrencyRates.convertCurrency(amount: costBasis, from: stock.currency, to: quote.currency, using: rates) {
                    stock.costBasis = converted
                }
                stock.price = quote.price
                stock.currency = quote.currency
                stock.priceUpdatedAt = .now
            }
        }
        return failures
    }

    static func refreshCrypto(in context: ModelContext) async -> Int {
        let coins = ((try? context.fetch(FetchDescriptor<Coin>())) ?? []).filter { !$0.id.isEmpty }
        guard !coins.isEmpty else { return 0 }

        guard let prices = try? await coinPrices.prices(ids: Array(Set(coins.map(\.id))).sorted()) else {
            return coins.count
        }
        var failures = 0
        for coin in coins {
            if let price = prices[coin.id] {
                coin.current_price = price
                coin.priceUpdatedAt = .now
            } else {
                failures += 1
            }
        }
        return failures
    }
}
