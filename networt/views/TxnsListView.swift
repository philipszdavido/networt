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
    @State var isEditMode = EditMode.inactive
    
    var filteredTxns: [Transaction] {
        if searchText.isEmpty {
            return txns
        } else {
            return txns.filter { txn in
                txn.currency.localizedStandardContains(searchText)
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
                            //Text("\(txn.bankInfo.bankName)")
                            Text("\(Time.formatDateTime(txn.dateTime))")
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
            
            
            .toolbar {
                if(isEditMode == .active) {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                print(selection)
                                
                                txns.forEach { txn in
                                    modelContext.delete(txn)
                                }
                                
                                isEditMode = .inactive

                            }, label: {
                                Text("Delete All")
                            }).disabled(selection.count != txns.count)
                            Spacer()
                            
                            Button(action: {
                                print(selection)
                                
                                selection.forEach { txn in
                                    modelContext.delete(txn)
                                }
                                
                                isEditMode = .inactive

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
            .environment(\.editMode, $isEditMode)
            .fontDesign(settings.fontDesign)
            
        }
    }
}

#Preview {
    TxnsListView().modelContainer(for: [
        Transaction.self, BankInfo.self
    ], inMemory: true).environmentObject(GlobalSettings())
}
