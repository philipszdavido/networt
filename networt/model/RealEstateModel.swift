//
//  RealEstateModel.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation
import SwiftData

@Model
class RentalIncome {
    var date: Date
    var amount: Double
    var currency: String
    var notes: String?

    init(date: Date, amount: Double, currency: String, notes: String? = nil) {
        self.date = date
        self.amount = amount
        self.notes = notes
        self.currency = currency
    }
}

@Model
class Property {
    var name: String
    var currency: String
    var purchasePrice: Double
    var marketValue: Double
    var appreciationPercent: Double
    var latitude: Double?
    var longitude: Double?
    var rentalIncomes: [RentalIncome] = []
    
    init(name: String, currency: String, purchasePrice: Double, marketValue: Double, appreciationPercent: Double) {
        self.name = name
        self.currency = currency
        self.purchasePrice = purchasePrice
        self.marketValue = marketValue
        self.appreciationPercent = appreciationPercent
    }

    var gain: Double {
        marketValue - purchasePrice
    }

    var roi: Double {
        (gain / purchasePrice) * 100
    }

    var totalRentalIncome: Double {
        rentalIncomes.map(\.amount).reduce(0, +)
    }
}

struct AppreciationPoint: Identifiable {
    let id = UUID()
    let year: Int
    var currency: String
    let estimatedValue: Double
}
