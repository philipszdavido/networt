//
//  LiabilityListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData

enum SortLiabilityType {
    case all
    case upcoming
    case sortduedate
}

struct LiabilityTag: Identifiable {
    var id: SortLiabilityType;
    var name: String
}

var tags : [LiabilityTag] = [
    LiabilityTag(id: .all, name: "All"),
    LiabilityTag(id: .upcoming, name: "Upcoming Only"),
    LiabilityTag(id: .sortduedate, name: "Sort by Due Date")
]

// MARK: - Main List View
struct LiabilityListView: View {

    @EnvironmentObject var settings: GlobalSettings
    @Query var liabilities: [Liability]
    @State private var showingAdd = false
    
    @State var selectedSector: SortLiabilityType? = .all;

    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Enter Liabilities").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                Spacer()
            }

            Text(
                "Track debt such as: Loans and Credit Cards"
            )
            .fontDesign(settings.fontDesign)
            
        }
        .padding(.bottom)
        .padding(.horizontal)

            VStack {
                
                Picker("Sector", selection: $selectedSector) {
                    ForEach(tags) { tag in
                        Text(tag.name)
                            .tag(Optional(tag.id))
                            .fontDesign(settings.fontDesign)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                
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
            .toolbar {
                Button(action: { showingAdd = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddLiabilityView()
            }
        
    }

    var groupedLiabilities: [LiabilityType: [Liability]] {
        Dictionary(grouping: liabilities) { $0.type }
    }
    
    func filteredAndSortedLiabilities(for type: LiabilityType) -> [Liability] {
        var list = groupedLiabilities[type] ?? []
        
        if selectedSector == .upcoming {
            let now = Date()
            list = list.filter { $0.dueDate ?? now >= now }
        }
        
        if selectedSector == .sortduedate {
            return list.sorted(by: { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) })
        } else {
            return list.sorted(by: { $0.balance > $1.balance })
        }
    }

}

#Preview {
    NavigationStack {
        
        LiabilityListView()
    }
        .modelContainer(for: [Liability.self, Payment.self])
        .environmentObject(GlobalSettings())
}
