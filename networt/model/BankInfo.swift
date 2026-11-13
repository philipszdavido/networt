//
//  BankInfo.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import Foundation
import SwiftData

@Model
class BankInfo {
    var balance: Double = 0
    var bankName: String = ""
    var currency: String = "USD"
    var number: Int = 0

    // Pre-1.1 stores kept whole units in an Int `amount` column. It is renamed here so the
    // store migrates automatically, then folded into `balance` by `LegacyMigration`.
    @Attribute(originalName: "amount") var legacyAmount: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Transaction.bankInfo) var transactions: [Transaction]? = []

    init(balance: Double, bankName: String, currency: String, number: Int) {
        self.balance = balance
        self.bankName = bankName
        self.currency = currency
        self.number = number
    }
}
