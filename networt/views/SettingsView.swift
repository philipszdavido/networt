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
                        Text("Global Currency")
                        
                        CurrencyPickerView(selection: $settings.currency)
                                    
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
    
    var filteredCurrencies: [(String, String, String, Double)] {
        let currencies = CurrencyRates.getAllRates(settings: self.settings).sorted { $0.1 < $1.1 }
        
        if searchText.isEmpty {
            return currencies
        }
            else {
                return currencies.filter({ (code, name, symbol, rate) in
                    name.localizedStandardContains(searchText)
                })
        }
    }

    var body: some View {
            List {
                Section("Conversion rates pegged at 1 USD") {
                    ForEach(filteredCurrencies, id: \.0) { code, name, symbol, rate in
                    
                        HStack {
                            Text("\(code) \(name)")
                            Spacer()
                            Text("\(rate)")
                        }
                    
                    
                }
            }
                
        }.searchable(text: $searchText)
            .toolbar {
                ToolbarItem {
                    Button("Refresh Rates") {
                        
                    }
                }
            }
    }
}
