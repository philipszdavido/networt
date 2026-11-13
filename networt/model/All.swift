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
    Property.self,
    NetWorthSnapshot.self
]

/// One-off data fixes that run on launch, after SwiftData's automatic migration.
enum LegacyMigration {

    /// Moves whole-unit Int amounts from old stores into the Double balance columns.
    static func run(_ context: ModelContext) {
        let banks = (try? context.fetch(FetchDescriptor<BankInfo>(predicate: #Predicate { $0.legacyAmount != 0 }))) ?? []
        for bank in banks {
            bank.balance += Double(bank.legacyAmount)
            bank.legacyAmount = 0
        }

        let txns = (try? context.fetch(FetchDescriptor<Transaction>(predicate: #Predicate { $0.legacyAmount != 0 }))) ?? []
        for txn in txns {
            txn.value += Double(txn.legacyAmount)
            txn.legacyAmount = 0
        }

        if !banks.isEmpty || !txns.isEmpty {
            try? context.save()
        }
    }
}
