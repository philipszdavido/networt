//
//  Cash.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct Cash: View {
    
    @State var amount: String = "0";
    @State var bankInfo: BankInfo = BankInfo(amount: 0, bankName: "", currency: "USD", number: 0)
    
    private let cornerRadius: CGFloat = 2;
    
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Cash").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text(
                    "Let users manually record cash on hand (e.g., physical wallet money)."
                )
                .fontDesign(settings.fontDesign)
                
            }.padding(.bottom)
                .padding(.horizontal)
            
            VStack {
                
                NavigationLink(destination: CurrencyListPickerView(selection: $bankInfo.currency)) {
                    
                    HStack {
                        Text("Currency: \(bankInfo.currency.uppercased())")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .semibold,
                                    design: settings.fontDesign
                                        )
                            )
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    
                }
            }.padding(.horizontal)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                
                Text("Amount")
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: settings.fontDesign
                        )
                    )
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                
                VStack {
                    TextField("Amount, e.g 400", text: $amount)
                        .padding(10.0)
                        .contentMargins(1.0)
                        .textContentType(.name)
                        .font(.system(size: 20, weight: .semibold, design: settings.fontDesign))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(.primary)
                        .keyboardType(.numberPad)
                }.padding(.horizontal)
                
                Divider()
                
            }
            
            Spacer()
        }
    }
}

#Preview {
    
    Cash()
        .environmentObject(GlobalSettings())
}
