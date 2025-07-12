//
//  CashListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import SwiftUI
import SwiftData

struct CashListView: View {
    
    @Query var cashList: [Cash]
    @Environment(\.modelContext) var modelContext
    @State var search: String = ""
    
    var filter: [Cash] {
        if search.isEmpty {
            return cashList
        }
        
        var results: [Cash] = []
        
        results += cashList.filter { _cash in
            String(_cash.amount)
                .contains(search)
        }
        
        results += cashList.filter { _cash in
            return _cash.currency.lowercased()
                .contains(search.lowercased())
        }
        
        return results

    }

    var body: some View {
        List {
            ForEach(filter) { cash in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(cash.amount)").font(.headline)
                        Text(cash.currency.uppercased()).font(.subheadline).foregroundColor(.gray)
                    }
                    Spacer()
                    Text(cash.amount, format: .currency(code: cash.currency))
                        .font(.caption).foregroundColor(.secondary)
                }
            }.onDelete { IndexSet in
                deleteCash(IndexSet)
            }
        }
        .navigationTitle("All Cash")
        .searchable(text: $search)
        .onAppear {
            modelContext.insert(Cash(amount: 900000.0, currency: "usd"))
            modelContext.insert(Cash(amount: 80.0, currency: "ngn"))
            modelContext.insert(Cash(amount: 70.0, currency: "ghc"))
        }
        .toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    EditButton()
                }
        }
    }
    
    func deleteCash(_ indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(cashList[index])
        }
    }
}

#Preview {
    NavigationStack {
        CashListView()
    }
        .modelContainer(for: allModels, inMemory: true)
}
