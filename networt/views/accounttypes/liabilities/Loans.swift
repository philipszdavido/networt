//
//  Loans.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct Loans: View {
    
    @Binding var minPayment: Double?
    @Binding var interestRate: Double?
    @Binding var dueDate: Date
    var currency: String

    var body: some View {
        Section("Optional") {
            TextField("Min Payment", value: Binding($minPayment, default: 0), format: .currency(code: currency))
                .keyboardType(.decimalPad)
            TextField("Interest Rate (%)", value: Binding($interestRate, default: 0), format: .number)
                .keyboardType(.decimalPad)
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
        }    }
}

#Preview {
    Loans(
        minPayment: .constant(0.0),
        interestRate: .constant(0.0),
        dueDate: .constant(Date.now),
        currency: "usd"
    )
}
