//
//  Transaction.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import Foundation
import SwiftData

@Model
class Transaction {
    var dateTime: Date = Date.now
    var operation: String = "+"
    var value: Double = 0
    var currency: String = "USD"

    var bankInfo: BankInfo?

    // See `BankInfo.legacyAmount`.
    @Attribute(originalName: "amount") var legacyAmount: Int = 0

    init(dateTime: Date, operation: String, value: Double, currency: String, bankInfo: BankInfo? = nil) {
        self.dateTime = dateTime
        self.operation = operation
        self.value = value
        self.currency = currency
        self.bankInfo = bankInfo
    }
}
