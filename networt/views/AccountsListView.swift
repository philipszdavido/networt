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
    AccountsListView(settings: GlobalSettings()/*, searchText: ""*/).modelContainer(for: [
        BankInfo.self
    ], inMemory: true)//.environment(\.editMode, Binding.constant(EditMode.active))
}



struct EditAccountView: View {

    @Environment(\.modelContext) private var modelContext

    @Bindable var bankInfo: BankInfo;
        
    var onSave: () -> Void;
    
    @State var showSheet = false
    @State var txnAmount: Int = 0;
    
    @State var operation = "";
    
    @State var number = ""
    @State var amount = ""
    @State var bankName = ""
    @State var savingBankDetails = false
    
    init(bankInfo: BankInfo, onSave: @escaping () -> Void, number: String = "", amount: String = "", bankName: String = "") {

        self.bankInfo = bankInfo
        self.onSave = onSave
        
        self._number = State(initialValue: String(bankInfo.number))
        self._amount = State(initialValue: String(bankInfo.amount))
        self._bankName = State(initialValue: bankInfo.bankName)
    }
        
    var body: some View {
        VStack(alignment: .center) {
            CustomStringTextView(text: "Bank Name", link: $bankName)
            
            CustomStringTextView(text: "Bank Account", link: $number, keyboardType: UIKeyboardType.numberPad)
            
            CustomStringTextView(text: "Amount", link: $amount, keyboardType: UIKeyboardType.numberPad)
            
            HStack {
                HStack {
                    
                    NavigationLink(destination: CurrencyListPickerView(selection: $bankInfo.currency)) {
                        HStack {
                            Group {
                                Text("Select Currency")
                                Text(bankInfo.currency.uppercased())
                                
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.leading, 5.0)
                            .foregroundColor(.blue)
                            .underline(true)
                            
                        }
                    }
                    
                    
                }.padding(.leading, 5.0)
                
                Spacer()
            }
            
            Spacer()
            
                
        }
        .overlay(alignment: .top) {
            if savingBankDetails { ProgressView("Loading...").frame(width: 100, height: 100)
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: {
                txnAmount = 0;
                operation = ""
            }) {
                VStack {
                    Text("Enter amount...").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal)
                        .foregroundColor(.gray)

                    HStack {
                        TextField("Amount...", value: $txnAmount, format: .number)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color(red: 0.8, green: 0.8, blue: 0.8))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        Button("Save", action: {
                            switch operation {
                            case "+":
                                bankInfo.amount = bankInfo.amount + txnAmount
                            case "-":
                                bankInfo.amount = bankInfo.amount - txnAmount
                            default: break
                                
                            }
                            
                            let txn = Transaction(dateTime: Date(), operation: operation, amount: txnAmount, currency: bankInfo.currency)
                            
                            //bankInfo.transactions.append(txn)
                            
                            modelContext.insert(txn)
                            showSheet.toggle()
                        })

                    }
                    
                }.padding()
                Spacer()
                .presentationDetents([.height(250)])
            }
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
                
                ToolbarItem {
                    Button("Save") {
                        
                        savingBankDetails = true
                        
                        if !amount.isEmpty {
                            if let amount = Int(amount) {
                                bankInfo.amount = amount
                            }
                        }
                        
                        bankInfo.bankName = bankName
                        
                        if !number.isEmpty {
                            if let number = Int(number) {
                                bankInfo.number = number
                            }
                        }
                        
                        savingBankDetails = false
                        
                    }
                }
                
            }
    }
    
}


struct CustomStringTextView: View {
    
    var text: String;
    @Binding var link: String;
    
    var keyboardType: UIKeyboardType = UIKeyboardType.default
        
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("\(text)").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal)
                .foregroundColor(.gray)

                TextField("\(text)", text: $link)
                .keyboardType(keyboardType)
                .disableAutocorrection(true)
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
