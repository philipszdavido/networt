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
                Text("$\(liability.balance, specifier: "%.2f")")
                    .foregroundStyle(.red)
            }
        }
    }
}
//
//#Preview {
//    LiabilityListItemView()
//}
