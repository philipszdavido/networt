//
//  AddPropertyView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct AddPropertyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var purchasePrice = ""
    @State private var marketValue = ""
    @State private var appreciation = ""
    @State private var currency: String = "usd"

    var body: some View {
        Form {
            Section("Property Info") {
                CurrencySelector(currency: $currency)
                TextField("Name", text: $name)
                TextField("Purchase Price", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                TextField("Market Value", text: $marketValue)
                    .keyboardType(.decimalPad)
                TextField("Appreciation (%)", text: $appreciation)
                    .keyboardType(.decimalPad)
            }

            Button("Save") {
                let newProperty = Property(
                    name: name, currency: currency,
                    purchasePrice: Double(purchasePrice) ?? 0,
                    marketValue: Double(marketValue) ?? 0,
                    appreciationPercent: Double(appreciation) ?? 0
                )
                context.insert(newProperty)
                dismiss()
            }
        }
    }
}

#Preview {
    AddPropertyView()
}
