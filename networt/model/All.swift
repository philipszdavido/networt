//
//  All.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation
import SwiftData

let allModels: [any PersistentModel.Type] = [
    Transaction.self,
    BankInfo.self,
    Cash.self,
    Coin.self,
    CoinHolding.self,
    Stock.self,
    Liability.self,
    Payment.self,
    RentalIncome.self,
    Property.self
]
