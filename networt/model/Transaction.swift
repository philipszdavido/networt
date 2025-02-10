//
//  Transaction.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import Foundation

import Foundation
import SwiftData

@Model
class Transaction: Hashable {
    var dateTime: Date;
    var operation: String;
    var amount: Int;
    var currency: String;
    
    var bankInfo: BankInfo;
    
    init(dateTime: Date, operation: String, amount: Int, currency: String, bankInfo: BankInfo) {
        self.dateTime = dateTime
        self.operation = operation
        self.amount = amount
        self.currency = currency
        self.bankInfo = bankInfo
    }
    
    // ✅ Implement Hashable
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.dateTime == rhs.dateTime &&
               lhs.operation == rhs.operation &&
               lhs.amount == rhs.amount &&
               lhs.currency == rhs.currency &&
               lhs.bankInfo == rhs.bankInfo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dateTime)
        hasher.combine(operation)
        hasher.combine(amount)
        hasher.combine(currency)
        hasher.combine(bankInfo)
    }
        
}
