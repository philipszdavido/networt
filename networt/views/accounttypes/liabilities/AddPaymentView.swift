//
//  AddPaymentView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Add Payment
struct AddPaymentView: View {
    @Bindable var liability: Liability
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double = 0
    @State private var date: Date = .now
    @State private var note: String = ""
    @State private var currency: String = "USD"

    var body: some View {
        NavigationStack {
            Form {
                CurrencySelector(currency: $currency)
                TextField(
                    "Amount",
                    value: $amount,
                    format: .currency(code: currency)
                )
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Note", text: $note)
            }
            .navigationTitle("Add Payment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let payment = Payment(
                            currency: currency,
                            amount: amount,
                            date: date,
                            note: note
                        )
                        liability.payments.append(payment)
                        liability.balance -= amount
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
    AddPaymentView(
        liability: Liability(
            name: "Inv",
            type: LiabilityType.creditCard, currency: "usd",
            balance: 900.0
        )
    ).environmentObject(GlobalSettings())
}
