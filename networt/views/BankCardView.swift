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
                
                Text(settings.hideNetworth ? getLengthOfAmount() : "\(bankInfo.currency.uppercased()) \(bankInfo.amount)").font(.system(.title, design: .rounded))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()

            }
                
        }.padding([.leading, .trailing, .bottom], 20)
            .padding(.top, 12)
         .frame(height: 120)
         .frame(width: 300)
         .background(settings.bankCardBgColor)
         //.cornerRadius(20.0)
         .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
//         .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
         .shadow(color: Color.black.opacity(0.2), radius: 4)
    }
    
}

#Preview {
    BankCardView(bankInfo: BankInfo(amount: 9087878787878787800, bankName: "Sterling Bank", currency: "USD", number: 90987878787877), settings:  GlobalSettings())
}
    

