//
//  CreditCard.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct CreditCard: View {
    
    @EnvironmentObject var settings: GlobalSettings

    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Investments").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text("Support for multiple subtypes: Stocks, Cryptocurrency, Real Estate"
                )
                .fontDesign(settings.fontDesign)
                
            }.padding(.bottom)
                .padding(.horizontal)
        }
    }
}

#Preview {
    CreditCard()
        .environmentObject(GlobalSettings())
}
