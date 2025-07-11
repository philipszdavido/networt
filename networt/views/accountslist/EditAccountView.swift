//
//  EditAccountView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct EditAccountView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: GlobalSettings

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
                            .font(.system(size: 20, weight: .semibold, design: settings.fontDesign))
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
                    Text("Enter amount...")
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold,
                                design: settings.fontDesign
                            )
                        )
                        .padding(.horizontal)
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


#Preview {
    NavigationView {
        
        EditAccountView(
            bankInfo: BankInfo(amount: 90, bankName: "UBA", currency: "NGN", number: 90),
            onSave: {}
        )
    }
        .modelContainer(for: [
        BankInfo.self
    ], inMemory: true)
        .environmentObject(GlobalSettings())
        
}
