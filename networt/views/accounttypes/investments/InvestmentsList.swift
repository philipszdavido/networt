//
//  InvestmentsList.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import SwiftUI
import SwiftData

struct InvestmentsList: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var settings: GlobalSettings

    @Query var stocks: [Stock]
    @Query var properties: [Property]
    @Query var coinHoldings: [CoinHolding]
    
    @State var search: String = ""
    
    var lowercasedSearch: String {
        search.lowercased()
    }
    
    var filterStocks: [Stock] {
        if search.isEmpty {
            return stocks
        }
        
        return stocks.filter { stock in
            stock.name.lowercased().contains(lowercasedSearch)
        }
    }
    
    var filterProperties: [Property] {
        if search.isEmpty {
            return properties
        }
        
        return properties.filter { property in
            property.name.lowercased().contains(lowercasedSearch)
        }

    }
    
    var filterCoins: [CoinHolding] {
        if search.isEmpty {
            return coinHoldings
        }
        
        return coinHoldings.filter { coin in
            coin.coin.name.lowercased().contains(lowercasedSearch)
        }
    }

    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Investments").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                Spacer()
            }

            Text(
                "Track your investments such as: Stocks, Cryptos and Properties"
            )
            .fontDesign(settings.fontDesign)
            
        }
        .padding(.bottom)
        .padding(.horizontal)

        List {
            Section("Stocks") {
                ForEach(filterStocks) { stock in
                    
                    StockRowView(stock: stock)
                    
                }
                .onDelete { IndexSet in
                    delete(IndexSet, from: stocks)
                }
            }

            Section("Crypto") {
                ForEach(filterCoins) { coin in
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // Header Row: Name + Symbol + Price
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(coin.coin.name)
                                    .font(.headline)

                                Label(coin.coin.symbol.uppercased(), systemImage: "bitcoinsign.circle")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .labelStyle(.titleAndIcon)
                            }

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(coin.coin.current_price, specifier: "%.2f")")
                                    .font(.headline)
                            }
                        }

                        // Details: Amount & Total Value
                        VStack(spacing: 4) {
                            HStack {
                                Label("Amount", systemImage: "number.circle")
                                Spacer()
                                Text("\(coin.amount, specifier: "%.4f")")
                                    .fontWeight(.medium)
                            }

                            HStack {
                                Label("Total", systemImage: "chart.bar")
                                Spacer()
                                Text("$\(coin.totalValue, specifier: "%.2f")")
                                    .fontWeight(.medium)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .onDelete { indexSet in
                    delete(indexSet, from: coinHoldings)
                }
            }

            Section("Properties/Real Estate") {

                    ForEach(filterProperties) { property in

                        PropertyCardView(property: property)
                            
                        
                    }.onDelete { IndexSet in
                        delete(IndexSet, from: properties)
                    }

            }

        }
        .searchable(text: $search)
        .toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    EditButton()
                }
        }
        .onAppear {
            populateDumbData()
        }
    }
    
    func delete<T: PersistentModel>(_ indexSet: IndexSet, from model: [T]) {
        for index in indexSet {
            modelContext.delete(model[index])
        }
    }
    
    func populateDumbData() {
        for _ in 0..<5 {
            let currentStock = Stock(
                symbol: "EXP",
                name: "Expat",
                sector: "Finance",
                exchange: "EXP"
            )
            
            currentStock.price = 90.0
            currentStock.quantity = 9000
            
            modelContext.insert(currentStock)
        }
        
        for _ in 0..<5 {
            modelContext
                .insert(
                    CoinHolding(
                        coin: Coin(id: "uiiop", symbol: "OPI", name: "Nop", current_price: 90.0),
                        amount: 90.0
                    )
                )
        }
        
        for _ in 0..<5 {
            modelContext
                .insert(
                    Property(
                        name: "Rental",
                        currency: "ngn",
                        purchasePrice: 890.0,
                        marketValue: 789.0,
                        appreciationPercent: 8.0
                    )
                )
        }
    }

}

#Preview {
    NavigationStack {
        InvestmentsList()
    }
        .environmentObject(GlobalSettings())
        .modelContainer(for: allModels, inMemory: true)

}

struct StockRowView: View {
    var stock: Stock

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top: Symbol and Name
            HStack {
                Text(stock.symbol)
                    .font(.headline)
                Spacer()
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Middle: Exchange and Sector
            Text("\(stock.exchange) • \(stock.sector)")
                .font(.caption)
                .foregroundColor(.gray)

            // Bottom: Quantity and Price
            HStack {
                Label("Qty", systemImage: "number.circle")
                Spacer()
                Text("\(stock.quantity)")
            }

            HStack {
                Label("Price", systemImage: "dollarsign.circle")
                Spacer()
                Text("$\(stock.price)")
            }
        }
        .padding(.vertical, 8)
        .font(.subheadline)
    }
}

struct PropertyCardView: View {
    var property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and ROI
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name)
                        .font(.headline)

                    Text("Purchase: \(format(property.purchasePrice, currency: property.currency))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Market: \(format(property.marketValue, currency: property.currency))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("ROI")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(String(format: "%.1f%%", property.roi))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(property.roi >= 0 ? .green : .red)
                }
            }

            // Income and Gain Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("Rental Income")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(format(property.totalRentalIncome, currency: property.currency))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Gain")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(format(property.gain, currency: property.currency))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 8)
    }

    func format(_ value: Double, currency: String) -> String {
        "\(currency) \(String(format: "%.2f", value))"
    }
}
