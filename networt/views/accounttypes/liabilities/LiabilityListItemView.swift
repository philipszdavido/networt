//
//  LiabilityListItemView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI


struct LiabilityListItemView: View {
    
    var liability: Liability
    
    var body: some View {
        NavigationLink(destination: LiabilityDetailView(liability: liability)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(liability.name)
                        .font(.headline)
                    if let due = liability.dueDate {
                        Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                    }
                }
                Spacer()
                Text(liability.balance, format: .currency(code: liability.currency))

                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    LiabilityListItemView(
        liability: Liability(
            name: "Inv",
            type: LiabilityType.creditCard, currency: "usd",
            balance: 100.0
        )
    )
}
