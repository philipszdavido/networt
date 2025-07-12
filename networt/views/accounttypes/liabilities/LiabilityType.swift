//
//  LiabilityType.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation

enum LiabilityType: String, CaseIterable, Codable, Identifiable {
    case loan = "Loan"
    case creditCard = "Credit Card"
    var id: String { rawValue }
}
