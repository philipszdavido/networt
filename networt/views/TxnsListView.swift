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
    @Environment(\.presentationMode) var presentationMode

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
    
    @State private var selection = Set<Transaction>()
    
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
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
            .navigationBarTitle("Transaction Updates", displayMode: .inline)
            .searchable(text: $searchText)
            .onAppear(perform: {
                
            })
            .navigationBarItems(trailing: Button(action : {
                presentationMode.wrappedValue.dismiss()
            }){
                EditButton()
                                
            })
            
//            Button(action: {
//                
//                let tempTxn = Transaction(dateTime: Date(), operation: "-", amount: 9000, currency: "NGN", bankInfo: BankInfo(amount: 0, bankName: "UBA", currency: "NGN", number: 34540))
//                
//                modelContext.insert(tempTxn)
//                
//        }, label: {
//            Text("Test")
//        })
            
            .toolbar {
                if(selection.count > 0) {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                print(selection)
                                
                                txns.forEach { txn in
                                    modelContext.delete(txn)
                                }

                            }, label: {
                                Text("Delete All")
                            }).disabled(selection.count != txns.count)
                            Spacer()
                            
                            Button(action: {
                                print(selection)
                                
                                txns.forEach { txn in
                                    modelContext.delete(txn)
                                }

                            }, label: {
                                Text("Delete")
                            }).disabled(selection.count <= 0)
                            Spacer()
                            
                            Button(action: {
                                txns.forEach { txn in
                                    selection.insert(txn)
                                }
                            }, label: {
                                Text("Select All")
                            }).disabled(selection.count == txns.count)
                        }
                    }
                }
            }


        }
    }
}

#Preview {
    TxnsListView().modelContainer(for: [
        Transaction.self, BankInfo.self
    ], inMemory: true)
}
