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
    var amount: Int;
    var bankName: String;
    var currency: String;
    var number: Int;
    
//    @Relationship(deleteRule: .cascade) var transactions = [Transaction]()
    init(amount: Int, bankName: String, currency: String, number: Int) {
        self.amount = amount
        self.bankName = bankName
        self.currency = currency
        self.number = number
    }
}

