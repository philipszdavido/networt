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

    var body: some View {
        NavigationStack {
            Text("Enter Bank").font(.system(size: 30, weight: .bold, design: .rounded))
                .padding(.bottom, 10)
            
            VStack(alignment: .leading) {
                
                Text("Bank Name").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                
                
                VStack {
                    TextField("Bank Name", text: $bankInfo.bankName)
                        .padding(10.0)
                        //.padding(.horizontal)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)

                }.padding(.horizontal)
                
                Divider()
                
            }
            
            VStack(alignment: .leading) {
                
                Text("Bank Account").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                
                
                
                VStack {
                    TextField("Bank Account", value: $bankInfo.number, format: .number)
                        .keyboardType(.numberPad)
                        .padding(10.0)
                        //.padding(.horizontal)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)
                }.padding(.horizontal)
                
                
                Divider()
                
            }
            
            
            VStack(alignment: .leading) {
                
                Text("Amount").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                
                
                VStack {
                    TextField("Amount", value: $bankInfo.amount, format: .number)
                        .padding(10.0)
                        //.padding(.horizontal)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .foregroundColor(.primary)
                .keyboardType(.numberPad)
                }.padding(.horizontal)
                
                Divider()
                
            }
                        
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Select Currency").font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.gray)
                    
                    CurrencyPickerView(selection: $bankInfo.currency)
                                        
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
                presentationMode.wrappedValue.dismiss()
                modelContext.insert(bankInfo)
            }){
                Text("Save")
            }
        })
        .navigationBarTitle("", displayMode: .inline)
        
    }
    
}

#Preview {
    //AddBankAccount(states: States())
    AddBankAccount()
}
