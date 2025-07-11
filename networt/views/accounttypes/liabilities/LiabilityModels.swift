//
//  Untitled.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftData
import Charts
import Foundation

// MARK: - Models

enum LiabilityType: String, CaseIterable, Codable, Identifiable {
    case loan = "Loan"
    case creditCard = "Credit Card"
    var id: String { rawValue }
}

@Model
class Liability {
    var name: String
    var type: LiabilityType
    var balance: Double
    var creditLimit: Double?
    var minPayment: Double?
    var interestRate: Double?
    var dueDate: Date?
    var payments: [Payment] = []

    init(name: String, type: LiabilityType, balance: Double, creditLimit: Double? = nil, minPayment: Double? = nil, interestRate: Double? = nil, dueDate: Date? = nil) {
        self.name = name
        self.type = type
        self.balance = balance
        self.creditLimit = creditLimit
        self.minPayment = minPayment
        self.interestRate = interestRate
        self.dueDate = dueDate
    }
}

@Model
class Payment {
    var amount: Double
    var date: Date
    var note: String?

    init(amount: Double, date: Date, note: String? = nil) {
        self.amount = amount
        self.date = date
        self.note = note
    }
}
