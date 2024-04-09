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
    
    var body: some View {
        NavigationView {
            List {
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
                            Text(settings.hideNetworth ? "*****" : "\(bankInfo.currency) \(bankInfo.amount)")
                        }
                    }
                }.onDelete { (indexSet) in
                    for offset in indexSet {
                        modelContext.delete(bankInfos[offset])
                    }
                        
                }
                
            }.onAppear(perform: {
//                modelContext.insert(BankInfo(amount: 0, bankName: "UBA", currency: "NGN", number: 34540))
//                modelContext.insert(BankInfo(amount: 0, bankName: "Sterling", currency: "EUR", number: 90))
        })
            .searchable(text: $searchText)
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: AddBankAccount(states: States())) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                    }
                }
            }
            
        }
    }
    
//    init(settings: GlobalSettings, searchText: String? = "") {
//        self.settings = settings;
//        self._bankInfos = Query(
//            filter: #Predicate<BankInfo> {
//                $0.bankName.contains(searchText!)
//            })
//    }
}

#Preview {
    AccountsListView(settings: GlobalSettings()/*, searchText: ""*/).modelContainer(for: [
        BankInfo.self
    ], inMemory: true)
}



struct EditAccountView: View {

    @Environment(\.modelContext) private var modelContext

    @Bindable var bankInfo: BankInfo;
    
    var onSave: () -> Void;
    
    @State var showSheet = false
    @State var amount: Int = 0;
    
    @State var operation = "";
    
    var body: some View {

        CustomStringTextView(text: "Bank Name", link: $bankInfo.bankName)
        
        CustomNumberTextView(text: "Bank Account", link: $bankInfo.number)
        
        CustomNumberTextView(text: "Amount", link: $bankInfo.amount)
        
        HStack {
            HStack {
                Text("Global Currency").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.leading, 5.0)
                    .foregroundColor(.gray)
                
                Picker(selection: $bankInfo.currency, label: Text("")) {
                    ForEach(currenciesWithFlags, id: \.0) { name, flag in
                                    Text("\(name) \(flag)")
                                }
                            }
                .pickerStyle(DefaultPickerStyle())
            }.padding(.leading, 5.0)
                        
            Spacer()
        }

        Spacer()

            .toolbar {
                ToolbarItem {
                    Button("Withdraw") {
                        operation = "-"
                        showSheet.toggle()
                    }

                }
                
                ToolbarItem {
                    Button("Add Money") {
                        operation = "+"
                        showSheet.toggle()
                    }

                }

            }.sheet(isPresented: $showSheet, onDismiss: {
                amount = 0;
                operation = ""
            }) {
                VStack {
                    Text("Enter amount...").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal)
                        .foregroundColor(.gray)

                    HStack {
                        TextField("Amount...", value: $amount, format: .number)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color(red: 0.8, green: 0.8, blue: 0.8))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        Button("Save", action: {
                            switch operation {
                            case "+":
                                bankInfo.amount = bankInfo.amount + amount
                            case "-":
                                bankInfo.amount = bankInfo.amount - amount
                            default: break
                                
                            }
                            
                            let txn = Transaction(dateTime: Date(), operation: operation, amount: amount, currency: bankInfo.currency, bankInfo: bankInfo)
                            
                            //bankInfo.transactions.append(txn)
                            
                            modelContext.insert(txn)
                            showSheet.toggle()
                        })

                    }
                    
                }.padding()
                Spacer()
                .presentationDetents([.height(250)])
            }
    }
}


struct CustomStringTextView: View {
    
    var text: String;
    @Binding var link: String;
        
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("\(text)").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal)
                .foregroundColor(.gray)

                TextField("\(text)", text: $link)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
            
            Divider()
            
        }
    }
}


struct CustomNumberTextView: View {
    
    var text: String;
    @Binding var link: Int;
        
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("\(text)").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                        
            TextField("\(text)", value: $link, format: .number)
                    .disableAutocorrection(true)
            .keyboardType(.numberPad)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
            
            Divider()
            
        }
    }
}
