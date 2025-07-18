//
//  LiabilityDetailView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Detail View
struct LiabilityDetailView: View {
    @Bindable var liability: Liability
    @Environment(\.modelContext) private var context
    @State private var showingAddPayment = false

    var body: some View {
        Form {
            Section("Summary") {
                Text("Name: \(liability.name)")
                Text("Type: \(liability.type.rawValue)")
                Text("Balance: \(liability.balance, format: .currency(code: liability.currency))")
                if let limit = liability.creditLimit {
                    Text("Credit Limit: \(limit, format: .currency(code: liability.currency))")
                }
                if let due = liability.dueDate {
                    Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                }
            }

            Section("Payment History") {
                ForEach(liability.payments.sorted(by: { $0.date > $1.date })) { payment in
                    VStack(alignment: .leading) {

                        Text(payment.amount, format: .currency(code: payment.currency))

                        Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                    }
                }
                Button("Add Payment") {
                    showingAddPayment = true
                }
            }
        }
        .navigationTitle(liability.name)
        .sheet(isPresented: $showingAddPayment) {
            AddPaymentView(liability: liability)
        }
    }
}

#Preview {
    LiabilityDetailView(
        liability: Liability(
            name: "Bal",
            type: LiabilityType.loan,
            currency: "ghc",
            balance: 90.0
        )
    )
}
