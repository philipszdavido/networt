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
@Model
class Liability {
    var name: String
    var type: LiabilityType
    var currency: String;
    var balance: Double
    var creditLimit: Double?
    var minPayment: Double?
    var interestRate: Double?
    var dueDate: Date?
    var payments: [Payment] = []

    init(name: String, type: LiabilityType, currency: String, balance: Double, creditLimit: Double? = nil, minPayment: Double? = nil, interestRate: Double? = nil, dueDate: Date? = nil) {
        self.name = name
        self.type = type
        self.balance = balance
        self.creditLimit = creditLimit
        self.minPayment = minPayment
        self.interestRate = interestRate
        self.dueDate = dueDate
        self.currency = currency
    }
}

@Model
class Payment {
    var currency: String;
    var amount: Double
    var date: Date
    var note: String?

    init(currency: String, amount: Double, date: Date, note: String? = nil) {
        self.amount = amount
        self.date = date
        self.note = note
        self.currency = currency
    }
}
