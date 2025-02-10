//
//  CurrencyListPickerView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/20/24.
//

import SwiftUI

struct CurrencyListPickerView: View {

    @Binding var selection: String
    @State var currencySelection: String?

    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditMode = EditMode.inactive
    @State var searchText = ""
    
    var filteredCurrencies: [(String, Double)] {
        let currencies = CurrencyRates.getAllRates(settings: self.settings).sorted { $0.0 < $1.0 }
        
        if searchText.isEmpty {
            return currencies
        }
        else {
            return currencies.filter({ (code, rate) in
                code.localizedStandardContains(searchText) || CurrencyRates.getCurrencyName(code: code, data: settings.currencyCodes).localizedStandardContains(searchText)
            })
        }
    }

    var body: some View {
        List(selection: $currencySelection) {
            ForEach(filteredCurrencies, id: \.0) { code, rate in
                HStack {
                    Text("\(code.uppercased()) \(CurrencyRates.getCurrencyName(code: code, data: settings.currencyCodes))")
                    Spacer()
                    Text("\(rate)")
                    if currencySelection == code {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .onTapGesture {
                    currencySelection = code
                }
            }
            .navigationTitle("Select Currency")
        }
        
        .searchable(text: $searchText)
        .environment(\.editMode, $isEditMode)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let currentSelection = currencySelection {
                    Button("Select") {
                        selection = currentSelection
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    CurrencyListPickerView(selection: .constant(""))
        .environmentObject(GlobalSettings())
}
