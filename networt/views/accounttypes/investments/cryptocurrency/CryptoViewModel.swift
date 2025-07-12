//
//  CryptoViewModel.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation

class CryptoViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var loading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var fetchSuccess: Bool = false

    func fetchCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd") else {
            errorMessage = "Invalid URL"
            return
        }

        loading = true
        errorMessage = nil
        fetchSuccess = false
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.loading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode([Coin].self, from: data)
                    self.coins = decoded
                    self.fetchSuccess = true
                } catch {
                    self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
