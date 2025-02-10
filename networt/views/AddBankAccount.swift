//
//  AddBankAccount.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import SwiftUI
import SwiftData
import UIKit

struct AddBankAccount: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    //@ObservedObject var states: States
    
    @State var bankInfo: BankInfo = BankInfo(amount: 0, bankName: "", currency: "USD", number: 0)
    
    @State private var amount = "";
    @State private var number = "";
    
    private let cornerRadius: CGFloat = 2;

    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                HStack {
                    Text("Enter Bank").font(.system(size: 30, weight: .bold, design: .default))
                        //.padding(.bottom, 10)
                    Spacer()
                }
                
                HStack {
                    Text("Your bank details are encrypted and only visible to you.")
                    Spacer()
                }

            }.padding(.horizontal)
                .padding(.bottom, 30)
            
            VStack(alignment: .leading) {
                
                Text("Bank Name").font(.system(size: 15, weight: .semibold, design: .default)).padding(.horizontal).foregroundColor(.gray)
                
                VStack {
                    TextField("Bank Name, e.g United Bank", text: $bankInfo.bankName)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)

                }.padding(.horizontal)
                
                Divider()
                
            }
            
            VStack(alignment: .leading) {
                
                Text("Bank Account").font(.system(size: 15, weight: .semibold, design: .default)).padding(.horizontal).foregroundColor(.gray)
                
                
                
                VStack {
                    TextField("Bank Account, e.g 324XXX", text: $number)
                        .keyboardType(.numberPad)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)
                }.padding(.horizontal)
                
                
                Divider()
                
            }
            
            
            VStack(alignment: .leading) {
                
                Text("Amount").font(.system(size: 15, weight: .semibold, design: .default)).padding(.horizontal).foregroundColor(.gray)
                
                VStack {
                    TextField("Amount, e.g 400", text: $amount)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)
                    .keyboardType(.numberPad)
                }.padding(.horizontal)
                
                Divider()
                
            }
                        
            
            HStack {
                VStack(alignment: .leading) {
                    
                    
                    NavigationLink(destination: CurrencyListPickerView(selection: $bankInfo.currency)) {
                            
                        HStack {
                            Text("Currency: \(bankInfo.currency.uppercased())")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        
                    }
                                        
                }
                Spacer()
            }.padding(.horizontal)
                .padding(.top)
            
            Spacer()
            
        }
        
        .navigationBarItems(trailing: Button(action : {
            presentationMode.wrappedValue.dismiss()
        }){
            Button(action: {

                if let amountWraped = Int(amount), let bankAccount = Int(number) {

                    bankInfo.amount = amountWraped
                    bankInfo.number = bankAccount

                }

                modelContext.insert(bankInfo)
                try! modelContext.save()
                
                presentationMode.wrappedValue.dismiss()
            }){
                Text("Save")
            }.disabled(bankInfo.bankName.isEmpty || amount.isEmpty || number.isEmpty)
        })
        .navigationBarTitle("", displayMode: .inline)
        
    }
    
}

#Preview {
    AddBankAccount()
}
