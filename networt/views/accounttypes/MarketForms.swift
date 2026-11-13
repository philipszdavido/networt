//
//  MarketForms.swift
//  networt
//
//  Add and edit forms for holdings with live prices: stocks and crypto.
//

import SwiftUI
import SwiftData

struct StockListing: Identifiable, Hashable {
    var symbol: String
    var name: String
    var sector: String
    var exchange: String

    var id: String { symbol }

    /// Suggestions shown before searching. Any other Yahoo Finance symbol can be typed in.
    static let catalog: [StockListing] = [
        .init(symbol: "AAPL", name: "Apple Inc.", sector: "Technology", exchange: "NASDAQ"),
        .init(symbol: "MSFT", name: "Microsoft Corp.", sector: "Technology", exchange: "NASDAQ"),
        .init(symbol: "GOOGL", name: "Alphabet Inc.", sector: "Technology", exchange: "NASDAQ"),
        .init(symbol: "NVDA", name: "NVIDIA Corp.", sector: "Technology", exchange: "NASDAQ"),
        .init(symbol: "AMZN", name: "Amazon.com Inc.", sector: "Retail", exchange: "NASDAQ"),
        .init(symbol: "VOO", name: "Vanguard S&P 500 ETF", sector: "ETF", exchange: "NYSE"),
        .init(symbol: "VTI", name: "Vanguard Total Stock Market ETF", sector: "ETF", exchange: "NYSE"),
        .init(symbol: "JPM", name: "JPMorgan Chase & Co.", sector: "Finance", exchange: "NYSE"),
        .init(symbol: "BAC", name: "Bank of America", sector: "Finance", exchange: "NYSE"),
        .init(symbol: "JNJ", name: "Johnson & Johnson", sector: "Healthcare", exchange: "NYSE"),
        .init(symbol: "PFE", name: "Pfizer Inc.", sector: "Healthcare", exchange: "NYSE"),
        .init(symbol: "WMT", name: "Walmart Inc.", sector: "Retail", exchange: "NYSE"),
        .init(symbol: "XOM", name: "ExxonMobil", sector: "Energy", exchange: "NYSE"),
        .init(symbol: "CVX", name: "Chevron", sector: "Energy", exchange: "NYSE"),
        .init(symbol: "RELIANCE.NS", name: "Reliance Industries", sector: "Energy", exchange: "NSE"),
        .init(symbol: "INFY.NS", name: "Infosys Ltd", sector: "Technology", exchange: "NSE"),
        .init(symbol: "HSBA.L", name: "HSBC Holdings", sector: "Finance", exchange: "LSE"),
        .init(symbol: "BP.L", name: "BP plc", sector: "Energy", exchange: "LSE"),
    ]
}

// MARK: - Stocks

struct StockForm: View {
    var stock: Stock?

    @Environment(\.modelContext) private var modelContext

    @State private var listing: StockListing?
    @State private var quote: StockQuote?
    @State private var loadingQuote = false
    @State private var shares = ""
    @State private var costBasis = ""
    @State private var loaded = false

    /// The quote's currency, else the stock's existing one, else USD.
    var currency: String {
        quote?.currency ?? stock?.currency ?? "USD"
    }

    var body: some View {
        Form {
            Section {
                if let stock {
                    LabeledContent(stock.symbol, value: stock.name)
                } else {
                    NavigationLink {
                        StockSearchView(selection: $listing)
                    } label: {
                        if let listing {
                            LabeledContent(listing.symbol, value: listing.name)
                        } else {
                            Text("Choose a stock").foregroundStyle(Color.accentColor)
                        }
                    }
                }
                if loadingQuote {
                    LabeledContent("Price") { ProgressView() }
                } else if let quote {
                    LabeledContent("Price", value: quote.price.money(quote.currency))
                } else if listing != nil {
                    Text("No live price. The purchase price is used until prices refresh.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                AmountField(title: "Shares", text: $shares, prompt: "0")
                AmountField(title: "Average cost", text: $costBasis, currency: currency, prompt: "Per share")
            } footer: {
                Text("Your average purchase price per share. Used to show your gain or loss.")
            }
        }
        .navigationTitle(stock == nil ? "New stock" : "Edit \(stock!.symbol)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: (stock != nil || listing != nil) && (Int(shares) ?? 0) > 0 && (stock != nil || quote != nil || Double.parse(costBasis) != nil)) {
                save()
            }
        }
        .task(id: listing) {
            guard let listing else { return }
            loadingQuote = true
            quote = try? await PriceRefresher.stockQuotes.quote(symbol: listing.symbol)
            loadingQuote = false
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            if let stock {
                shares = String(stock.quantity)
                costBasis = stock.costBasis.fieldText
            }
        }
    }

    func save() {
        let cost = Double.parse(costBasis)
        if let stock {
            stock.quantity = Int(shares) ?? stock.quantity
            stock.costBasis = cost
            return
        }
        guard let listing else { return }
        let newStock = Stock(symbol: listing.symbol, name: listing.name, sector: listing.sector, exchange: listing.exchange)
        newStock.quantity = Int(shares) ?? 0
        newStock.currency = currency
        newStock.costBasis = cost
        newStock.price = quote?.price ?? cost ?? 0
        newStock.priceUpdatedAt = quote == nil ? nil : .now
        modelContext.insert(newStock)
    }
}

struct StockSearchView: View {
    @Binding var selection: StockListing?

    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var results: [StockListing] {
        guard !search.isEmpty else { return StockListing.catalog }
        return StockListing.catalog.filter { $0.symbol.localizedStandardContains(search) || $0.name.localizedStandardContains(search) }
    }

    var customSymbol: String {
        search.trimmingCharacters(in: .whitespaces).uppercased()
    }

    var body: some View {
        List {
            if !customSymbol.isEmpty && !results.contains(where: { $0.symbol == customSymbol }) {
                Section {
                    Button {
                        select(StockListing(symbol: customSymbol, name: customSymbol, sector: "", exchange: ""))
                    } label: {
                        Label("Use “\(customSymbol)”", systemImage: "magnifyingglass")
                    }
                } footer: {
                    Text("Any Yahoo Finance symbol works, e.g. TSLA, VWRL.L or 7203.T.")
                }
            }
            Section(search.isEmpty ? "Popular" : "Matches") {
                ForEach(results) { listing in
                    Button {
                        select(listing)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(listing.symbol).font(.body.weight(.semibold))
                                Text(listing.name).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(listing.exchange)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Symbol or company")
        .textInputAutocapitalization(.characters)
        .navigationTitle("Stocks")
        .navigationBarTitleDisplayMode(.inline)
    }

    func select(_ listing: StockListing) {
        selection = listing
        dismiss()
    }
}

// MARK: - Crypto

@Observable
@MainActor
final class CoinMarket {
    var coins: [Coin] = []
    var loading = false
    var errorMessage: String?

    @ObservationIgnored var load: DataLoader = urlSessionLoader

    func fetch() async {
        guard coins.isEmpty, let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&per_page=250") else { return }
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            coins = try JSONDecoder().decode([Coin].self, from: try await load(url))
        } catch {
            errorMessage = "Couldn't load coins. Check your connection."
        }
    }
}

/// A chosen coin, kept as plain values so nothing is inserted until Save.
struct CoinChoice: Hashable {
    var id: String
    var symbol: String
    var name: String
    var price: Double
}

struct CryptoForm: View {
    var holding: CoinHolding?

    @Environment(\.modelContext) private var modelContext

    @State private var choice: CoinChoice?
    @State private var amount = ""
    @State private var costBasis = ""
    @State private var loaded = false

    var body: some View {
        Form {
            Section {
                if let holding {
                    LabeledContent(holding.symbol, value: holding.name)
                } else {
                    NavigationLink {
                        CoinSearchView(selection: $choice)
                    } label: {
                        if let choice {
                            LabeledContent(choice.symbol.uppercased(), value: choice.name)
                        } else {
                            Text("Choose a coin").foregroundStyle(Color.accentColor)
                        }
                    }
                }
                if let price = choice?.price ?? holding?.price {
                    LabeledContent("Price", value: price.money("USD"))
                }
            }
            Section {
                AmountField(title: "Amount", text: $amount, currency: choice?.symbol ?? holding?.symbol, prompt: "0")
                AmountField(title: "Average cost", text: $costBasis, currency: "USD", prompt: "Optional")
            } footer: {
                Text("Your average purchase price per coin. Used to show your gain or loss.")
            }
        }
        .navigationTitle(holding == nil ? "New crypto" : "Edit \(holding!.symbol)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: (holding != nil || choice != nil) && (Double.parse(amount) ?? 0) > 0) {
                save()
            }
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            if let holding {
                amount = holding.amount.fieldText
                costBasis = holding.costBasis.fieldText
            }
        }
    }

    func save() {
        let value = Double.parse(amount) ?? 0
        let cost = Double.parse(costBasis)
        if let holding {
            holding.amount = value
            holding.costBasis = cost
            return
        }
        guard let choice else { return }

        // Reuse the stored coin so every holding of it shares one price.
        let coinID = choice.id
        let coin = (try? modelContext.fetch(FetchDescriptor<Coin>(predicate: #Predicate { $0.id == coinID })))?.first
            ?? Coin(id: choice.id, symbol: choice.symbol, name: choice.name, current_price: choice.price)
        coin.current_price = choice.price
        coin.priceUpdatedAt = .now

        let newHolding = CoinHolding(coin: coin, amount: value)
        newHolding.costBasis = cost
        modelContext.insert(newHolding)
    }
}

struct CoinSearchView: View {
    @Binding var selection: CoinChoice?

    @Environment(\.dismiss) private var dismiss
    @State private var market = CoinMarket()
    @State private var search = ""

    var results: [Coin] {
        guard !search.isEmpty else { return market.coins }
        return market.coins.filter { $0.name.localizedStandardContains(search) || $0.symbol.localizedStandardContains(search) }
    }

    var body: some View {
        List(results) { coin in
            Button {
                selection = CoinChoice(id: coin.id, symbol: coin.symbol, name: coin.name, price: coin.current_price)
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coin.name).font(.body.weight(.medium))
                        Text(coin.symbol.uppercased()).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(coin.current_price.money("USD"))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
        .overlay {
            if market.loading {
                ProgressView()
            } else if let error = market.errorMessage {
                ContentUnavailableView {
                    Label("Coins unavailable", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try again") { Task { await market.fetch() } }
                }
            } else if results.isEmpty && !search.isEmpty {
                ContentUnavailableView.search(text: search)
            }
        }
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Coin name or symbol")
        .navigationTitle("Crypto")
        .navigationBarTitleDisplayMode(.inline)
        .task { await market.fetch() }
    }
}

#Preview {
    NavigationStack {
        StockForm()
    }
    .modelContainer(for: allModels, inMemory: true)
    .environment(GlobalSettings())
}
