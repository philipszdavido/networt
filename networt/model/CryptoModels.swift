//
//  models.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import Foundation
import SwiftData

@Model
class Coin: Decodable, Identifiable {
    var id: String
    var symbol: String
    var name: String
    var current_price: Double
    
    init(id: String, symbol: String, name: String, current_price: Double) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.current_price = current_price
    }
    
    // Decodable conformance
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let name = try container.decode(String.self, forKey: .name)
        let current_price = try container.decode(Double.self, forKey: .current_price)
        
        self.init(id: id, symbol: symbol, name: name, current_price: current_price)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case current_price
    }
}

@Model
class CoinHolding: Identifiable {
    var id = UUID()
    var coin: Coin
    var amount: Double
    
    var totalValue: Double {
        amount * coin.current_price
    }
    
    init(coin: Coin, amount: Double) {
        self.coin = coin
        self.amount = amount
    }
}

