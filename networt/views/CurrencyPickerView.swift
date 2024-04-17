//
//  CurrencyPickerView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/13/24.
//

import SwiftUI

struct CurrencyPickerView: View {

    @Binding var selection: String;

    var body: some View {
        
        Picker(selection: $selection, label: Text("")) {
            ForEach(currenciesWithFlags.sorted { $0.2 < $1.2 }, id: \.0) { symbol, flag, currencyName, rate in
                            Text("\(flag) \(currencyName)")
                        }
        }
        .padding(0)
        .pickerStyle(DefaultPickerStyle())

    }
}

#Preview {
    CurrencyPickerView(selection: .constant("USD"))
}
