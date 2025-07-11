//
//  Stocks.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Foundation

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let sector: String
    let exchange: String // e.g., NASDAQ, NSE, Crypto
}

let stockList: [Stock] = [
    // U.S. Tech
    Stock(symbol: "AAPL", name: "Apple Inc.", sector: "Technology", exchange: "NASDAQ"),
    Stock(symbol: "MSFT", name: "Microsoft Corp.", sector: "Technology", exchange: "NASDAQ"),
    Stock(symbol: "GOOGL", name: "Alphabet Inc.", sector: "Technology", exchange: "NASDAQ"),
    Stock(symbol: "NVDA", name: "NVIDIA Corp.", sector: "Technology", exchange: "NASDAQ"),
    
    // Finance
    Stock(symbol: "JPM", name: "JPMorgan Chase & Co.", sector: "Finance", exchange: "NYSE"),
    Stock(symbol: "BAC", name: "Bank of America", sector: "Finance", exchange: "NYSE"),
    
    // Healthcare
    Stock(symbol: "JNJ", name: "Johnson & Johnson", sector: "Healthcare", exchange: "NYSE"),
    Stock(symbol: "PFE", name: "Pfizer Inc.", sector: "Healthcare", exchange: "NYSE"),
    
    // Retail
    Stock(symbol: "WMT", name: "Walmart Inc.", sector: "Retail", exchange: "NYSE"),
    Stock(symbol: "AMZN", name: "Amazon.com Inc.", sector: "Retail", exchange: "NASDAQ"),
    
    // Energy
    Stock(symbol: "XOM", name: "ExxonMobil", sector: "Energy", exchange: "NYSE"),
    Stock(symbol: "CVX", name: "Chevron", sector: "Energy", exchange: "NYSE"),

    // 🇮🇳 NSE India
    Stock(symbol: "RELIANCE.NS", name: "Reliance Industries", sector: "Energy", exchange: "NSE"),
    Stock(symbol: "INFY.NS", name: "Infosys Ltd", sector: "Technology", exchange: "NSE"),
    
    // 🇬🇧 LSE UK
    Stock(symbol: "HSBA.L", name: "HSBC Holdings", sector: "Finance", exchange: "LSE"),
    Stock(symbol: "BP.L", name: "BP plc", sector: "Energy", exchange: "LSE"),
    
    // 🪙 Crypto
    Stock(symbol: "BTC-USD", name: "Bitcoin", sector: "Cryptocurrency", exchange: "Crypto"),
    Stock(symbol: "ETH-USD", name: "Ethereum", sector: "Cryptocurrency", exchange: "Crypto")
]

struct Stocks: View {
    
    private let cornerRadius: CGFloat = 1.0
    @EnvironmentObject var settings: GlobalSettings
    
    @State var symbol: String = "0"
    @State var quantity: String = "0"
    @State var price: String = "0"

    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Stocks").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text("Support for multiple subtypes: Stocks, Cryptocurrency, Real Estate"
                )
                .fontDesign(settings.fontDesign)
                
            }.padding(.bottom)
                .padding(.horizontal)
            
            // MARK: -
            NavigationLink {
                StockListView()
            } label: {
                HStack {
                    Text("Select Stock Symbol")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }.padding(.horizontal)
                .padding(.bottom)

            // MARK: - Quantity
            VStack(alignment: .leading) {
                
                Text("Quantity")
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: settings.fontDesign
                        )
                    )
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                
                VStack {
                    TextField("Quantity, e.g 400", text: $quantity)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: settings.fontDesign))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(.primary)
                        .keyboardType(.numberPad)
                }.padding(.horizontal)
                
                Divider()
                
            }
            
            // MARK: - Price
            VStack(alignment: .leading) {
                
                Text("Price")
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: settings.fontDesign
                        )
                    )
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                
                VStack {
                    TextField("Price, e.g 400", text: $price)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: settings.fontDesign))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(.primary)
                        .keyboardType(.numberPad)
                }.padding(.horizontal)
                
                Divider()
                
            }
            Spacer()
        }
    }
}

struct StockListView: View {
    @State private var searchText = ""
    @State private var selectedSector: String? = nil
    
    var sectors: [String] {
        Set(stockList.map { $0.sector }).sorted()
    }
    
    var filteredStocks: [Stock] {
        stockList.filter { stock in
            (searchText.isEmpty || stock.name.localizedCaseInsensitiveContains(searchText) || stock.symbol.localizedCaseInsensitiveContains(searchText)) &&
            (selectedSector == nil || stock.sector == selectedSector)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Sector", selection: $selectedSector) {
                    Text("All").tag(String?.none)
                    ForEach(sectors, id: \.self) { sector in
                        Text(sector).tag(Optional(sector))
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                List(filteredStocks) { stock in
                    VStack(alignment: .leading) {
                        Text(stock.symbol).font(.headline)
                        Text(stock.name).font(.subheadline).foregroundColor(.gray)
                        Text("\(stock.exchange) - \(stock.sector)").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Stocks & Crypto")
            .searchable(text: $searchText, prompt: "Search by name or symbol")
        }
    }
}


#Preview {
    StockListView()
}

#Preview {
    Stocks() .environmentObject(GlobalSettings())
}
