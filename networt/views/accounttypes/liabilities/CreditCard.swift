//
//  CreditCard.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct CreditCard: View {
    
    @EnvironmentObject var settings: GlobalSettings
    @Binding var creditLimit: Double?
    var currency: String

    var body: some View {
        Section("Credit Card Info") {
            TextField("Credit Limit", value: Binding($creditLimit, default: 0), format: .currency(code: currency))
                .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    CreditCard(creditLimit: .constant(34.0), currency: "USD")
        .environmentObject(GlobalSettings())
}
