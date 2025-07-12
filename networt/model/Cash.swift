//
//  Cash.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation
import SwiftData

@Model
class Cash: Identifiable {
    var id = UUID()
    var amount: Double
    var currency: String
        
    init(amount: Double, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}
