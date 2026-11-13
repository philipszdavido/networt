//
//  LiabilityModels.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import Foundation
import SwiftData

enum LiabilityType: String, CaseIterable, Codable, Identifiable {
    case loan = "Loan"
    case creditCard = "Credit Card"

    var id: String { rawValue }
}

@Model
class Liability {
    var name: String = ""
    var type: LiabilityType = LiabilityType.loan
    var currency: String = "USD"
    var balance: Double = 0
    var creditLimit: Double?
    var minPayment: Double?
    var interestRate: Double?
    var dueDate: Date?
    @Relationship(deleteRule: .cascade, inverse: \Payment.liability) var payments: [Payment]? = []

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

    var paymentHistory: [Payment] {
        (payments ?? []).sorted { $0.date > $1.date }
    }

    /// Share of the credit limit in use, from 0 to 1.
    var utilization: Double? {
        guard let creditLimit, creditLimit > 0 else { return nil }
        return min(max(balance / creditLimit, 0), 1)
    }
}

@Model
class Payment {
    var currency: String = "USD"
    var amount: Double = 0
    var date: Date = Date.now
    var note: String?
    var liability: Liability?

    init(currency: String, amount: Double, date: Date, note: String? = nil) {
        self.amount = amount
        self.date = date
        self.note = note
        self.currency = currency
    }
}
