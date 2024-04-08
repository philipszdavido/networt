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
        
        var body: some View {
            
            HStack {
                Text("Txn Updates").font(.system(size: 20, design: .rounded)).bold()
                Spacer()
            }.padding(.leading, 7.0)
                .padding([.bottom], 0)
                .padding(.top, 15)
            Divider()
            
            List {
                ForEach(txns, id: \.self) { txn in
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
            }.edgesIgnoringSafeArea(.all)
                .padding(0)
                .listStyle(.plain)
                .onAppear(perform: {
//                    modelContext.insert(Transaction(dateTime: Date(), operation: "-", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "UBA", currency: "NGN", number: 90009876)))
//                    
//                    modelContext.insert(Transaction(dateTime: Date(), operation: "+", amount: 9000, currency: "USD", bankInfo: BankInfo(amount: 9000, bankName: "First Bank of Nigeria", currency: "EUR", number: 90009876)))
                })
        }
}

#Preview {
    UpdatesView(settings: GlobalSettings()).modelContainer(for: [
        BankInfo.self, Transaction.self
    ], inMemory: true)
}
