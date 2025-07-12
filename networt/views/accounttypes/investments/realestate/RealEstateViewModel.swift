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

    func addProperty(name: String, currency: String, purchasePrice: Double, marketValue: Double, appreciation: Double) {
        let newProperty = Property(
            name: name,
            currency: currency,
            purchasePrice: purchasePrice,
            marketValue: marketValue,
            appreciationPercent: appreciation
        )
        properties.append(newProperty)
    }
}
