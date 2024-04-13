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
                
                
                TextField("Bank Name", text: $bankInfo.bankName)
                    .textContentType(.name)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                
                Divider()
                
            }
            
            VStack(alignment: .leading) {
                
                Text("Bank Account").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                
                
                
                TextField("Bank Account", value: $bankInfo.number, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                
                
                Divider()
                
            }
            
            
            VStack(alignment: .leading) {
                
                Text("Amount").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)
                
                
                TextField("Amount", value: $bankInfo.amount, format: .number)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                    .keyboardType(.numberPad)
                
                Divider()
                
            }
                        
            
            HStack {
                HStack {
                    Text("Select Currency").font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.gray)
                    
                    CurrencyPickerView(selection: $bankInfo.currency)
                                        
                }
                Spacer()
            }.padding(.horizontal)
            
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
