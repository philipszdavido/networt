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
    var date: Date = Date.now
    var amount: Double = 0
    var currency: String = "USD"
    var notes: String?
    var property: Property?

    init(date: Date, amount: Double, currency: String, notes: String? = nil) {
        self.date = date
        self.amount = amount
        self.notes = notes
        self.currency = currency
    }
}

@Model
class Property {
    var name: String = ""
    var currency: String = "USD"
    var purchasePrice: Double = 0
    var marketValue: Double = 0
    var appreciationPercent: Double = 0
    var latitude: Double?
    var longitude: Double?
    @Relationship(deleteRule: .cascade, inverse: \RentalIncome.property) var rentalIncomes: [RentalIncome]? = []

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
        purchasePrice > 0 ? (gain / purchasePrice) * 100 : 0
    }

    var totalRentalIncome: Double {
        (rentalIncomes ?? []).map(\.amount).reduce(0, +)
    }

    /// Projected value after `years`, compounding `appreciationPercent` from today's market value.
    func projectedValue(afterYears years: Int) -> Double {
        marketValue * pow(1 + appreciationPercent / 100, Double(years))
    }
}
