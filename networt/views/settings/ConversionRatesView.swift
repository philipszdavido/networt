//
//  ConversionRatesView.swift
//  networt
//
//  Created by Chidume Nnamdi on 10/02/2025.
//

import SwiftUI

struct ConversionRatesView: View {
    @ObservedObject var settings: GlobalSettings;
    @State var searchText = ""
    
    @State var refreshingRates = false
    
    var filteredCurrencies: [(String, Double)] {
        let currencies = CurrencyRates.getAllRates(settings: self.settings).sorted { $0.0 < $1.0 }
        
        if searchText.isEmpty {
            return currencies
        }
            else {
                return currencies.filter({ (code, rate) in
                    code.localizedStandardContains(searchText)
                })
        }
    }

    var body: some View {
            List {
                Section("Conversion rates pegged at 1 \(settings.currencyRates.type.uppercased())") {
                    ForEach(filteredCurrencies, id: \.0) { code, rate in
                    
                        HStack {
                            Text("\(code.uppercased()) \(CurrencyRates.getCurrencyName(code: code, data: settings.currencyCodes))")
                            Spacer()
                            Text("\(rate)")
                        }
                    
                    
                }
            }
                
            }.navigationTitle("\((Time.dateFromString( settings.currencyRates.date)))")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem {
                    Button(refreshingRates ? "Refreshing rates..." : "Refresh Rates") {
                        
                            refreshingRates = true
                        
                            Task {
                                
                                do {

                                    settings.currencyRates = try await CurrencyRates.fetchCurrencyRates()
                                    refreshingRates = false
                                    
                                } catch {
                                    print(error)
                                    refreshingRates = false
                                }
                                
                            }
                        
                    }.disabled(refreshingRates)
                }
            }
    }
}

#Preview {
    ConversionRatesView(settings: GlobalSettings())
}
