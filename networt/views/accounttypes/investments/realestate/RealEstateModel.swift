//
//  models.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import Foundation
import SwiftData

class RealEstateViewModel: ObservableObject {
    @Published var properties: [Property] = []

    func addProperty(name: String, purchasePrice: Double, marketValue: Double, appreciation: Double) {
        let newProperty = Property(
            name: name,
            purchasePrice: purchasePrice,
            marketValue: marketValue,
            appreciationPercent: appreciation
        )
        properties.append(newProperty)
    }
}

@Model
class RentalIncome {
    var date: Date
    var amount: Double
    var notes: String?

    init(date: Date, amount: Double, notes: String? = nil) {
        self.date = date
        self.amount = amount
        self.notes = notes
    }
}

@Model
class Property {
    var name: String
    var purchasePrice: Double
    var marketValue: Double
    var appreciationPercent: Double
    var latitude: Double?
    var longitude: Double?
    var rentalIncomes: [RentalIncome] = []
    
    init(name: String, purchasePrice: Double, marketValue: Double, appreciationPercent: Double) {
        self.name = name
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
    let estimatedValue: Double
}
