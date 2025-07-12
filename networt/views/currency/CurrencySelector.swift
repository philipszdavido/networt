//
//  CurrencySelector.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import SwiftUI

struct CurrencySelector: View {
    
    @EnvironmentObject var settings: GlobalSettings
    @State var currency: String;
    
    var body: some View {
        VStack {
            
            NavigationLink(destination: CurrencyListPickerView(selection: $currency)) {
                
                HStack {
                    Text("Currency: \(currency.uppercased())")
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
    }
}

#Preview {
    NavigationStack {
        CurrencySelector(currency: "")
    }
        .environmentObject(GlobalSettings())
}
