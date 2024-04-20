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
                    TextField("Bank Account", text: $number)
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
                    TextField("Amount", text: $amount)
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
                    
                    
                    NavigationLink(destination: CurrencyListPickerView(selection: $bankInfo.currency)) {
                            
                        Text("Select Currency: \(bankInfo.currency.uppercased())").font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.blue)
                            .underline(true)
                        
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
    //AddBankAccount(states: States())
    AddBankAccount()
}
