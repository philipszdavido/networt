//
//  AddLiabilityView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Add Liability View
struct AddLiabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var type = LiabilityType.loan
    @State private var balance: Double = 0
    @State private var creditLimit: Double?
    @State private var minPayment: Double?
    @State private var interestRate: Double?
    @State private var dueDate: Date = .now
    @State private var currency: String = "USD"

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    CurrencySelector(currency: $currency)

                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(LiabilityType.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Balance", value: $balance, format: .currency(code: currency))
                        .keyboardType(.decimalPad)
                }

                if type == .creditCard {
                    CreditCard(creditLimit: $creditLimit, currency: currency)
                }

                Loans(
                    minPayment: $minPayment,
                    interestRate: $interestRate,
                    dueDate: $dueDate,
                    currency: currency
                )
                
            }
            .navigationTitle("New Liability")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        
                        let liability = Liability(
                            name: name,
                            type: type,
                            currency: currency,
                            balance: balance,
                            creditLimit: creditLimit,
                            minPayment: minPayment,
                            interestRate: interestRate,
                            dueDate: dueDate
                        )
                        context.insert(liability)
                        dismiss()
                        
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddLiabilityView()
        .environmentObject(GlobalSettings())
}
