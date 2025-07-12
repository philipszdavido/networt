//
//  NetworthView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/14/24.
//

import SwiftUI
import SwiftData
import Combine

struct NetworthView: View {
    
    @Query var bankInfos: [BankInfo]

    @State var selectedTab = 1
    
    var settings = GlobalSettings()
    
    @State var errorLoadingCurrencayRates = false
    
    var body: some View {
        if CurrencyRates.checkCurrencyRatesFawazahmed0IsEmpty(data: settings.currencyRates) || CurrencyRates.checkCurrencyCodesIsEmpty(data: settings.currencyCodes) {
            
            if errorLoadingCurrencayRates {
                Button("Retry") {
                    errorLoadingCurrencayRates = false
                    Task {
                        do {
                            try await settings.loadCurrency()
                            
                            try await settings.loadCurrencycodes()
                            
                        } catch {
                            errorLoadingCurrencayRates = true
                        }
                    }

                }
            }
            
            if !errorLoadingCurrencayRates {
                
                Text("There are no currency rates found. Loading from server...")
                
                ProgressView()
                    .onAppear(perform: {
                        
                        Task {
                            do {
                                try await settings.loadCurrency()

                                try await settings.loadCurrencycodes()

                                errorLoadingCurrencayRates = true
                            } catch {
                                errorLoadingCurrencayRates = true
                            }
                        }
                        
                    })
            }
            
        }
        else {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    
                    SummaryView(settings: settings)
                        .tabItem {
                            Label("Summary", systemImage: "dollarsign.circle")
                        }.tag(1)
                    
                    
                    MainView(bankInfos: bankInfos, settings: settings)
                        .tabItem {
                        Label("Overall", systemImage: "dollarsign.bank.building")
                    }.tag(2)
                    
                    NavigationView {
                        AccountsListView(settings: settings)
                    }.tabItem { Label("Accounts", systemImage: "person.3")
                    }.tag(3)
                    
                    SettingsView(settings: settings)
                        .tabItem { Label("Settings", systemImage: "gear") }
                        .tag(4)
                    
                }
            }
        }
        
    }
    
    init() {
        
        settings.loadSettings()
                
    }
}

#Preview {
    
    NetworthView()
        .modelContainer(for: allModels, inMemory: true)
        .environmentObject(GlobalSettings())

}
