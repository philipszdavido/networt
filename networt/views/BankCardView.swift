//
//  BankCardView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/8/24.
//

import SwiftUI

struct BankCardView: View {
    var bankInfo: BankInfo;
    var settings: GlobalSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(String(bankInfo.number))").bold().fontDesign(.rounded)
                Spacer()
                Text("\(String(bankInfo.bankName))").fontDesign(.rounded)
            }
            
            HStack {
                
                Text(settings.hideNetworth ? "****" : "\(bankInfo.currency) \(bankInfo.amount)").font(.system(.title, design: .rounded))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()

            }
                
        }.padding([.leading, .trailing, .bottom], 20)
            .frame(height: 120)
            .background(.purple)
            .cornerRadius(8.0)
    }
}

#Preview {
    BankCardView(bankInfo: BankInfo(amount: 9000, bankName: "Sterling Bank", currency: "USD", number: 090987656545), settings:  GlobalSettings())
}
    
