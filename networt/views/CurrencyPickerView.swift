//
//  CurrencyPickerView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/13/24.
//

import SwiftUI

struct CurrencyPickerView: View {

    @Binding var selection: String;
    
//    @State var currencies: [String: Double]

    @EnvironmentObject var settings: GlobalSettings

    var body: some View {
        
        Picker(selection: $selection, label: Text("")) {
            ForEach(settings.currencyRates.usd.sorted { $0.0 < $1.0 }, id: \.0) { code, rate in
                Text("\(code.uppercased()) \(CurrencyRates.getCurrencyName(code: code, data: settings.currencyCodes))")
                        }
        }
        .padding(0)
        .pickerStyle(DefaultPickerStyle())

    }
}

#Preview {
    CurrencyPickerView(selection: .constant("USD"))
        .environmentObject(GlobalSettings())
}
