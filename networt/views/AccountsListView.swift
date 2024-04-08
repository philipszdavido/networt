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

    @Query var bankInfos: [BankInfo]
    var settings: GlobalSettings

    var body: some View {
        NavigationView {
            List {
                ForEach(bankInfos, id: \.self) { bankInfo in
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
//                modelContext.insert(BankInfo(amount: 0, bankName: "Sterling", currency: "EUR", number: 90))
//                modelContext.insert(BankInfo(amount: 0, bankName: "UBA", currency: "NGN", number: 34540))
        })
            .navigationTitle("Accounts")
        }
    }
}

#Preview {
    AccountsListView(settings: GlobalSettings()).modelContainer(for: [
        BankInfo.self
    ], inMemory: true)
}



struct EditAccountView: View {

    @Environment(\.modelContext) private var modelContext

    @Bindable var bankInfo: BankInfo;
    
    var onSave: () -> Void;
    
    @State var showSheet = false
    @State var amount = 0
    
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
                    Button("Add") {
                        operation = "+"
                        showSheet.toggle()
                    }

                }

//                    ToolbarItem {
//                        Button("Save") {
//                            onSave()
//                        }
//                    }
            }.sheet(isPresented: $showSheet, onDismiss: {
                amount = 0;
                operation = ""
            }) {
                VStack {
                    Text("Enter amount...").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal)
                        .foregroundColor(.gray)

                    TextField("Amount...", value: $amount, format: .number)
                        .padding(10)
                        .background(.gray)
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
                        
                        modelContext.insert(txn)
                        showSheet.toggle()
                    })
                }.padding()
                Spacer()
                
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
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
            
            Divider()
            
        }
    }
}
