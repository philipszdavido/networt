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
                
                Section("Home Screen") {
                    
                    Toggle(isOn: $settings.showMyBanks) {
                        Text("Show My Banks")
                    }
                    
                    Toggle(isOn: $settings.hideNetworth) {
                        Text("Hide Net Worth")
                    }
                    
                    Toggle(isOn: $settings.showUpdates) {
                        Text("Show Updates")
                    }
                    
                    ColorPicker("Bank Card Color", selection: $settings.bankCardBgColor)
                                        
                }
                
                Section("Rates") {
                    NavigationLink(destination: ConversionRatesView(settings: settings), label: {
                        Text("See Conversion Rates")
                    })
                }
                
                Section("Font") {
                    NavigationLink(
                        destination: FontTypeView(settings: settings)
                    ) {
                            Text("Font Type")
                    }
                }
                
            }
            .navigationTitle("Settings")
        }
        
    }
}

#Preview {
    
    SettingsView(settings: GlobalSettings())
    
}
