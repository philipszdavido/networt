//
//  Stock.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation
import SwiftData

@Model
class Stock: Identifiable {
    var id = UUID()
    var symbol: String
    var name: String
    var sector: String
    var exchange: String
    
    var quantity: Int = 0;
    var price: Double = 0
    
    init(symbol: String, name: String, sector: String, exchange: String) {
        self.symbol = symbol
        self.name = name
        self.sector = sector
        self.exchange = exchange
    }
}
