//
//  SettingsView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var settings: GlobalSettings;
    
    var body: some View {
        
        NavigationView {
            List {
                                
                Section("Currency") {
                    HStack {
                        
                        NavigationLink(destination: CurrencyListPickerView(selection: $settings.currency)) {
                            HStack {
                                Text("Global Currency")
                                Spacer()
                                Text(settings.currency.uppercased())
                            }
                        }
                                    
                    }
                }
                
                Toggle(isOn: $settings.showMyBanks) {
                    Text("Show My Banks")
                }
                
                Toggle(isOn: $settings.hideNetworth) {
                    Text("Hide Net Worth")
                }
                
                Toggle(isOn: $settings.showUpdates) {
                    Text("Show Updates")
                }
                
                Section("Rates") {
                    NavigationLink(destination: ConversionRatesView(settings: settings), label: {
                        Text("See Conversion Rates")
                    })
                }
                
            }
            .navigationTitle("Settings")
        }
        
    }
}

#Preview {
    
    SettingsView(settings: GlobalSettings())
    
}

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
