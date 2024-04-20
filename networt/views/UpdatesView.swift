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
            Text("Txn Updates").font(.system(size: 20, design: .rounded)).bold()
            
            Spacer()
            
            if !txns.isEmpty {
                NavigationLink(destination: TxnsListView()) {
                    
                    Text("See all")
                    
                }
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
            
        }
        .padding([.bottom], 0)
        .padding(.top, 15)
        .listRowSeparator(.hidden)
        
        Divider().listRowSeparator(.hidden)
        if txns.isEmpty {
            
            Text("No txn updates").padding()
            
        } else {
        VStack {
            ForEach(txns, id: \.self) { txn in
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(txn.bankInfo.bankName)")
                        Text("\(Time.formatDateTime(txn.dateTime))")
                            .font(.system(.caption, design: .rounded))
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
            .onAppear(perform: {
                //                    for _ in 1...9 {
                //                        modelContext.insert(Transaction(dateTime: Date(), operation: "-", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "UBA", currency: "NGN", number: 90009876)))
                //
                //                        modelContext.insert(Transaction(dateTime: Date(), operation: "+", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "First Bank of Nigeria", currency: "EUR", number: 90009876)))
                //                    }
                
            })
    }
    }
}


#Preview {

UpdatesView(settings: GlobalSettings()).modelContainer(for: [
            BankInfo.self, Transaction.self
        ], inMemory: true)
}
