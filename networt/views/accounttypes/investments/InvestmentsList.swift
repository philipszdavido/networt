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
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stock.symbol).font(.headline)
                                Text(stock.name).font(.subheadline).foregroundColor(.gray)
                                Text("\(stock.exchange) - \(stock.sector)").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { IndexSet in
                        delete(IndexSet, from: stocks)
                    }
            }

            Section("Crypto") {
                
                    ForEach(filterCoins) { coin in
                            VStack(alignment: .leading) {
                                Text(coin.coin.name).font(.headline)
                                Text(coin.coin.symbol.uppercased()).font(.subheadline).foregroundColor(.gray)
                            }
                    }.onDelete { IndexSet in
                        delete(IndexSet, from: coinHoldings)
                    }

            
            }

            Section("Properties/Real Estate") {

                    ForEach(filterProperties) { property in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(property.name)").font(.headline)
                                Text(property.currency.uppercased()).font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(
                                property.purchasePrice,
                                format: .currency(code: property.currency)
                            )
                                .font(.caption).foregroundColor(.secondary)
                        }
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
            
        }
    }
    
    func delete<T: PersistentModel>(_ indexSet: IndexSet, from model: [T]) {
        for index in indexSet {
            modelContext.delete(model[index])
        }
    }
    
    func populateDumbData() {
        for _ in 0..<5 {
            modelContext.insert(Stock(symbol: "EXP", name: "Expat", sector: "Finance", exchange: "EXP"))
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
