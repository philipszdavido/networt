//
//  StockListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData


struct StockListView: View {
    @State private var searchText = ""
    @State private var selectedSector: String? = nil
    @Binding var selectedStock: Stock
    
    @Environment(\.dismiss) var dismiss

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
                HStack {
                    VStack(alignment: .leading) {
                        Text(stock.symbol).font(.headline)
                        Text(stock.name).font(.subheadline).foregroundColor(.gray)
                        Text("\(stock.exchange) - \(stock.sector)").font(.caption).foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if stock.id == selectedStock.id {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    
                }.onTapGesture {
                    selectedStock = stock
                }
            }
        }
        .navigationTitle("Stocks & Crypto")
        .searchable(text: $searchText, prompt: "Search by name or symbol")
        .toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    
                }
            
        }
    }
}


#Preview {
    NavigationStack {
        
        StockListView(
            selectedStock:
                    .constant(Stock(symbol: "", name: "", sector: "", exchange: ""))
        )
    }
}
