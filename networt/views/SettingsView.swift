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
        
        NavigationStack {
            List {
                                
                Section("Currency") {
                    HStack {
                        Text("Global Currency")
                        Picker(selection: $settings.currency, label: Text("")) {
                            ForEach(currenciesWithFlags, id: \.0) { name, flag in
                                            Text("\(name) \(flag)")
                                        }
                                    }
                                    .pickerStyle(DefaultPickerStyle())
                                    
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
                
            }
            .navigationTitle("Settings")
        }
        
    }
}

#Preview {
    
    SettingsView(settings: GlobalSettings())
    
}
