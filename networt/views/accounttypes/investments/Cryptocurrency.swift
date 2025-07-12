//
//  Cryptocurrency.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData

struct Cryptocurrency: View {
    
    private let cornerRadius: CGFloat = 1.0
    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @State var amount: String = "0"
    @State var coin: Coin?

    var body: some View {
        
        let coinBinding = Binding<Coin>(
            get: {
                coin ?? Coin(
                    id: "", symbol: "", name: "", current_price: 0.0
                )
            },
            set: {value in
                coin = value
            }
        )
        
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Crypto Currency")
                        .font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text("Support for multiple subtypes: Stocks, Cryptocurrency, Real Estate")
                    .fontDesign(settings.fontDesign)
                
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                // Coin Picker
                NavigationLink {
                    CryptoListView(selectedCoin: coinBinding)
                } label: {
                    HStack {
                        Text("Select Coin")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }.padding([.horizontal, .bottom])
            
            if let coin = coin {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(coin.symbol).font(.headline)
                        Text(coin.name).font(.subheadline).foregroundColor(.gray)
                        Text("\(coin.current_price)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }.padding(.horizontal)
                    .padding(.bottom)
            }
            
            // MARK: - Amount
            VStack(alignment: .leading) {
                
                Text("Amount")
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
                    TextField("Amount, e.g 400", text: $amount)
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
                        saveCoin()
                    } label: {
                        Text("Save")
                    }

                }
        }

    }
    
    func saveCoin() {
        
        if let coin = coin {
            
            let coinHolding = CoinHolding(
                coin: coin,
                amount: Double(amount) ?? 0.0
            )
            
            modelContext.insert(coinHolding)
            
        }
        
    }
    
}

#Preview {
    
    NavigationView {
        
        Cryptocurrency()
    }
        .modelContainer(for: [
            BankInfo.self, Transaction.self, Stock.self
        ], inMemory: true)
        .environmentObject(GlobalSettings())
    
}


#Preview {
    CryptoListView(
        selectedCoin: .constant(Coin(id: "", symbol: "", name: "", current_price: 0.0))
    )
}

