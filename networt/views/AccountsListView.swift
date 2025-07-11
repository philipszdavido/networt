//
//  AccountsListView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import SwiftUI
import SwiftData

struct AccountsListView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var isEditMode = EditMode.inactive
    
    var settings: GlobalSettings
    
    @State private var searchText: String = "";
    
    @Query(sort: [SortDescriptor(\BankInfo.bankName)]) var bankInfos: [BankInfo]
    
    var filteredBankInfos: [BankInfo] {
            if searchText.isEmpty {
                return bankInfos
            } else {
                return bankInfos.filter { $0.bankName.localizedStandardContains(searchText) }
            }
        }

    @State private var selection = Set<BankInfo>()
    @State private var isSelected = false;

    var body: some View {
        NavigationView {
            List(selection: $selection) {
                ForEach(filteredBankInfos, id: \.self) { bankInfo in
                    NavigationLink(
                        destination: EditAccountView(bankInfo: bankInfo, onSave: {
                            try! modelContext.save()
                        })
                        ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(bankInfo.bankName)")
                                Text("\(String(bankInfo.number))")
                            }
                            Spacer()
                            Text(settings.hideNetworth ? "*****" : "\(bankInfo.currency.uppercased()) \(bankInfo.amount)")
                        }
                    }
                }.onDelete { (indexSet) in
                    for offset in indexSet {
                        modelContext.delete(bankInfos[offset])
                    }
                        
                }
                
            }.onAppear(perform: {
                
            // MARK: always comment out
//                modelContext.insert(BankInfo(amount: 7000, bankName: "UBA", currency: "NGN", number: 345232340))
//                modelContext.insert(BankInfo(amount: 250, bankName: "Sterling", currency: "EUR", number: 2334343490))
                
        })
            .searchable(text: $searchText)
            .navigationTitle("Accounts")
            .toolbar {

                if !bankInfos.isEmpty {
                    ToolbarItem {
                        
                        EditButton()
                        
                    }
                }

                ToolbarItem {
                    NavigationLink(destination: AddBankAccount(settings: settings)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                    }
                }
                
                if(isEditMode == .active) {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                print(selection)
                                
                                bankInfos.forEach { txn in
                                    modelContext.delete(txn)
                                }

                                selection = Set<BankInfo>()
                                
                                isEditMode = .inactive

                            }, label: {
                                Text("Delete All")
                            }).disabled(selection.count <= 0 || selection.count != bankInfos.count)
                            Spacer()
                            
                            Button(action: {
                                print(selection)
                                
                                selection.forEach { txn in
                                    modelContext.delete(txn)
                                }
                                
                                selection = Set<BankInfo>()
                                isEditMode = .inactive

                            }, label: {
                                Text("Delete")
                            }).disabled(selection.count <= 0)
                            Spacer()
                            
                            Button(action: {
                                bankInfos.forEach { txn in
                                    selection.insert(txn)
                                }
                            }, label: {
                                Text("Select All")
                            }).disabled(selection.count == bankInfos.count)
                        }
                    }

                }

            }.environment(\.editMode, $isEditMode)
                .fontDesign(settings.fontDesign)
            
        }
    }
    
}

#Preview {
    AccountsListView(settings: GlobalSettings())
        .modelContainer(for: [
        BankInfo.self
    ], inMemory: true)
    .environmentObject(GlobalSettings())
}






