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
class Transaction {
    var dateTime: Date;
    var operation: String;
    var amount: Int;
    var currency: String;
    
//    var bankInfo: BankInfo;
    
    init(dateTime: Date, operation: String, amount: Int, currency: String) {
        self.dateTime = dateTime
        self.operation = operation
        self.amount = amount
        self.currency = currency
        //self.bankInfo = bankInfo
    }
}
