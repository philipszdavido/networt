//
//  Stocks.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Foundation
import SwiftData

struct Stocks: View {
    
    private let cornerRadius: CGFloat = 1.0
    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @State var stock: Stock? = nil
    @State var quantity: String = "0"
    @State var price: String = "0"
    
    var body: some View {
        VStack {
            
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
            
            // MARK: - Select Stock Symbol
            VStack(alignment: .leading) {
                NavigationLink {
                    
                    StockListView(selectedStock: Binding(get: {
                        stock ?? Stock(symbol: "", name: "", sector: "", exchange: "")
                    }, set: { Value in
                        stock = Value
                    }))
                    
                } label: {
                    HStack {
                        Text("Select Stock Symbol")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }.padding(.horizontal)
                    .padding(.bottom)
            }
            
            // MARK: - Select Stock Symbol
            if let stock = stock {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(stock.symbol).font(.headline)
                        Text(stock.name).font(.subheadline).foregroundColor(.gray)
                        Text("\(stock.exchange) - \(stock.sector)").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }.padding(.horizontal)
                    .padding(.bottom)
            }
            
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
        .toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    Button {
                        saveStock()
                    } label: {
                        Text("Save")
                    }
                    
                }
        }
        
    }
    
    func saveStock() {
        withAnimation {
            
            if let stock = stock {
                
                stock.quantity = Int(quantity) ?? 0
                stock.price = Double(price) ?? 0.0
                
                modelContext.insert(stock)
                
            }
            
        }
    }
}

#Preview {
    StockListView(
        selectedStock: .constant(Stock(symbol: "", name: "", sector: "", exchange: ""))
    )
}

#Preview {
    
    NavigationView {
        
        Stocks() .environmentObject(GlobalSettings())
        
    }.modelContainer(for: [
        BankInfo.self, Transaction.self, Stock.self
    ], inMemory: true)
    
}
