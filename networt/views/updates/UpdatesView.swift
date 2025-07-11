//
//  UpdatesView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/8/24.
//

import SwiftUI
import SwiftData

struct UpdatesView: View {

    @Query var txns: [Transaction]
    @Environment(\.modelContext) private var modelContext

var settings: GlobalSettings
    
    var body: some View {
        
        HStack {
            Text("Txn Updates").font(.system(size: 20, design: settings.fontDesign)).bold()
            
            Spacer()
            
            if !txns.isEmpty {
                NavigationLink(destination: TxnsListView()) {
                    
                    Text("See all")
                    
                }
            } else {
                EmptyView()
            }
            
        }
        .padding([.bottom], 0)
        .padding(.top, 15)
        .listRowSeparator(.hidden)
        
        Divider().listRowSeparator(.hidden)
        if txns.isEmpty {
            
            Text("No txn updates")
                .font(.system(size: 19, design: settings.fontDesign))
                .padding()
            
        } else {
            VStack {
                ForEach(txns, id: \.self) { txn in
                    
                    HStack {
                        VStack(alignment: .leading) {
                            //Text("\(txn.bankInfo.bankName)")
                            Text("\(Time.formatDateTime(txn.dateTime))")
                                .font(.system(.caption, design: settings.fontDesign))
                        }
                        Spacer()
                        
                        Text(settings.hideNetworth ? "****" : "\(txn.operation) \(txn.currency) \(txn.amount)")
                    }
                    Divider()
                }.onDelete { (indexSet) in
                    for offset in indexSet {
                        modelContext.delete(txns[offset])
                    }
                }
            }.listRowSeparator(.hidden)
                .onAppear(perform: {})
                .fontDesign(settings.fontDesign)
        }
    }
}


struct UpdatesViewPreview: View {
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        
        UpdatesView(
            settings: GlobalSettings())
        .modelContainer(for: [
            BankInfo.self,
            Transaction.self], inMemory: true)
        .onAppear(perform: {
                                for _ in 1...9 {
                                    modelContext.insert(Transaction(dateTime: Date(), operation: "-", amount: 9000, currency: "USD"))
            
                                    modelContext.insert(Transaction(dateTime: Date(), operation: "+", amount: 9000, currency: "USD"))
                                }
            
        })
        
    }
}

#Preview {
    UpdatesViewPreview()
}
