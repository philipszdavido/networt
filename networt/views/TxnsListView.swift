//
//  TxnsListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/14/24.
//

import SwiftUI
import SwiftData

struct TxnsListView: View {
    @Query var txns: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: GlobalSettings
    
    @State var searchText = ""

    func formatDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, h:mm a"
        
        _ = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, " + dateFormatter.string(from: date)
        } else if Calendar.current.isDateInToday(date) {
            return "Today, " + dateFormatter.string(from: date)
        } else {
            return dateFormatter.string(from: date)
        }
    }
    
    var filteredTxns: [Transaction] {
        if searchText.isEmpty {
            return txns
        } else {
            return txns.filter { txn in
                txn.bankInfo.bankName.localizedStandardContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTxns, id: \.self) { txn in
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(txn.bankInfo.bankName)")
                            Text("\(formatDateTime(txn.dateTime))")
                                .font(.system(.caption, design: .rounded))
                        }
                        Spacer()
                        
                        Text(settings.hideNetworth ? "****" : "\(txn.operation) \(txn.currency) \(txn.amount)")
                    }

                }.onDelete { (indexSet) in
                    for offset in indexSet {
                        modelContext.delete(txns[offset])
                    }
                }
            }
            .navigationTitle("Transaction Updates")
            .searchable(text: $searchText)
            .onAppear(perform: {
//                                    for _ in 1...9 {
//                                        modelContext.insert(Transaction(dateTime: Date(), operation: "-", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "UBA", currency: "NGN", number: 90009876)))
//                
//                                        modelContext.insert(Transaction(dateTime: Date(), operation: "+", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "First Bank of Nigeria", currency: "EUR", number: 90009876)))
//                                    }
                
            })

        }
    }
}

#Preview {
    TxnsListView().modelContainer(for: [
        BankInfo.self, Transaction.self
    ], inMemory: true)
}
