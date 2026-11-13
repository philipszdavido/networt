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
    var amount: Double = 0
    var currency: String = "USD"
    var label: String = ""

    init(amount: Double, currency: String, label: String = "") {
        self.amount = amount
        self.currency = currency
        self.label = label
    }

    var displayName: String {
        label.isEmpty ? "Cash" : label
    }
}
