//
//  CryptoListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Foundation

struct CryptoListView: View {

    @StateObject var viewModel = CryptoViewModel()
    @Binding var selectedCoin: Coin
    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        if viewModel.errorMessage != nil {
            Button {
                viewModel.fetchCoins()
            } label: {
                Text("Retry")
            }

        }
        
        if viewModel.loading {
            ProgressView()
        }
        
        List(viewModel.coins) { coin in
            HStack {
                VStack(alignment: .leading) {
                    Text(coin.name).font(.headline)
                    Text(coin.symbol.uppercased()).font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                
                if selectedCoin.id == coin.id {
                    Image(systemName: "checkmark.circle.fill")
                }
                
                Text("$\(coin.current_price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.green)
            }.onTapGesture {
                selectedCoin = coin
            }
        }
        .onAppear {
            viewModel.fetchCoins()
        }
        .navigationTitle("Live Crypto Prices")
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
    CryptoListView(
        selectedCoin: .constant(Coin(id: "", symbol: "", name: "", current_price: 0.0))
    )
}
