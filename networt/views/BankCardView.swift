//
//  BankCardView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/8/24.
//

import SwiftUI

struct BankCardView: View {
    
    var bankInfo: BankInfo;
    
    @ObservedObject var settings: GlobalSettings
    
    func getLengthOfAmount() -> String {
        let cur = bankInfo.currency.count;
        let amt = String(bankInfo.amount).count
        
        return Array(1...(cur + amt)).map{ item in
        "*"
        }.joined()
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(String(bankInfo.number))").bold().fontDesign(.rounded)
                Spacer()
                Text("\(String(bankInfo.bankName))").fontDesign(.rounded)
            }
            
            HStack {
                
                Text(settings.hideNetworth ? getLengthOfAmount() : "\(bankInfo.currency) \(bankInfo.amount)").font(.system(.title, design: .rounded))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()

            }
                
        }.padding([.leading, .trailing, .bottom], 20)
         .frame(height: 120)
         .background(.purple)
         .cornerRadius(20.0)
         .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
}

#Preview {
    BankCardView(bankInfo: BankInfo(amount: 9000, bankName: "Sterling Bank", currency: "USD", number: 090987656545), settings:  GlobalSettings())
}
    

