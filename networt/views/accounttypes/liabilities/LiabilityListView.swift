//
//  LiabilityListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData

// MARK: - Main List View
struct LiabilityListView: View {
    @Query var liabilities: [Liability]
    @State private var showingAdd = false
    @State private var sortByDueDate = false
    @State private var showUpcomingOnly = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Toggle("Upcoming Only", isOn: $showUpcomingOnly)
                    Spacer()
                    Toggle("Sort by Due Date", isOn: $sortByDueDate)
                }
                .padding([.horizontal, .top])

                let sortedTypes = groupedLiabilities.keys.sorted(by: { $0.rawValue < $1.rawValue })

                List {
                    ForEach(sortedTypes, id: \.self) { type in
                        let liabilitiesForType = filteredAndSortedLiabilities(for: type)
                        Section(header: Text(type.rawValue)) {
                            ForEach(liabilitiesForType) { liability in
                                LiabilityListItemView(liability: liability)
                            }
                        }
                    }
                }

                PieChartView(liabilities: liabilities)
                    .frame(height: 300)
            }
            .navigationTitle("Liabilities")
            .toolbar {
                Button(action: { showingAdd = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddLiabilityView()
            }
        }
    }

    var groupedLiabilities: [LiabilityType: [Liability]] {
        Dictionary(grouping: liabilities) { $0.type }
    }
    
    func filteredAndSortedLiabilities(for type: LiabilityType) -> [Liability] {
        var list = groupedLiabilities[type] ?? []
        
        if showUpcomingOnly {
            let now = Date()
            list = list.filter { $0.dueDate ?? now >= now }
        }
        
        if sortByDueDate {
            return list.sorted(by: { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) })
        } else {
            return list.sorted(by: { $0.balance > $1.balance })
        }
    }

}

#Preview {
    LiabilityListView()
        .modelContainer(for: [Liability.self, Payment.self])
}
