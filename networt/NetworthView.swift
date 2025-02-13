//
//  NetworthView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/14/24.
//

import SwiftUI
import SwiftData
import Combine

class States: ObservableObject {
    @Published var addNewAccount: Bool = false;
}

struct NetworthView: View {
    
    @Query var bankInfos: [BankInfo]

    @State var selectedTab = 1
    
    var settings = GlobalSettings()
    
    
    @StateObject var states = States()
    
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
                    
                    MainView(bankInfos: bankInfos, settings: settings, states: states).tabItem {
                        Label("Home", systemImage: "dollarsign.circle")
                    }.tag(1)
                    
                    
                    AccountsListView(settings: settings).tabItem { Label("Accounts", systemImage: "person.3")
                    }.tag(2)
                    
                    SettingsView(settings: settings).tabItem { Label("Settings", systemImage: "gear") }.tag(3)
                    
                }
            }.onAppear(perform: {
            })
        }
        
    }
    
    init() {
        
        settings.loadSettings()
                
    }
}

#Preview {
    
    NetworthView()
        .modelContainer(for: [
            BankInfo.self, Transaction.self
        ], inMemory: true)
        .environmentObject(GlobalSettings())

}

struct MainView: View {
    
    var bankInfos: [BankInfo]
    
    @ObservedObject var settings: GlobalSettings
    
    @ObservedObject var states: States;

    @Environment(\.modelContext) private var modelContext

    @State private var networth: Double = 0.0;
    
    @State var toogleSheet = false
    
    @State var searchText = ""
        
    func getCode(curr: String) -> String {

        let codeRateDict = settings.currencyRates.data.first { (code, rate) in
            code == curr.lowercased()
        }
        
        
        if let codeRateDict = codeRateDict {
            return codeRateDict.0.uppercased()
        }
        
        return ""
//        return settings.currencyRates.usd.first { (code, rate) in
//            code.localizedStandardContains(curr)
//        }!.0
    }
    
    func calcNetworth() -> Double {
        return bankInfos.map { bankInfo in

            return CurrencyRates.convertToGlobalCurrency(bankInfo, settings)
        }.reduce(0, +)
    }
        
    var sortCurrencies: [(String, Double)] {
        let temCurrencies = CurrencyRates.getAllRates(settings: self.settings).sorted { $0.0 < $1.0 }
        
        if searchText.isEmpty {
            return temCurrencies
        }
        else {
            return temCurrencies.filter { (code, rate) in
                code.localizedStandardContains(searchText) || getCode(curr: code).localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
         
        VStack {
            
            HStack {
                Text("My Net Worth")
                    .font(.system(.largeTitle, design: settings.fontDesign))
                    .bold()
                .fontWeight(.black)
                Spacer()
                HeaderMenuView(states: states)
                NavigationLink(destination: AddBankAccount(settings: settings)) {
                                Image(systemName: "plus.circle.fill").font(.system(.largeTitle, design: settings.fontDesign))
                                    .padding(.trailing, 4.0)
                            }
            }.padding([.horizontal, .vertical])

            ScrollView {
                
                Section {
                    HStack {
                        
                        HStack(alignment: .top) {
                            
                            Text("\(getCode(curr: settings.currency))").underline(true).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/).font(.system(size: 50, design: settings.fontDesign))
                                .fontWeight(.black)
                                .onTapGesture {
                                    toogleSheet.toggle()
                                }.sheet(isPresented: $toogleSheet, onDismiss: {
                                }) {
                                    NavigationView {
                                        List {
                                            
                                            ForEach(sortCurrencies, id: \.0) { code, rate in
                                                Button(action: {
                                                    settings.currency = code
                                                    networth = calcNetworth()
                                                    toogleSheet.toggle()
                                                }) {
                                                    HStack {
                                                        Text("\(code.uppercased()) \(CurrencyRates.getCurrencyName(code: code, data: settings.currencyCodes))")
                                                            .font(.system(size: 15))
                                                            .fontWeight(.medium)
                                                        Spacer()
                                                    }
                                                }
                                                
                                            }
                                        }.listStyle(PlainListStyle()) .searchable(text: $searchText)
                                        
                                            .navigationBarItems(trailing: Button("Done",
                                                                                    action: {
                                                toogleSheet.toggle()
                                            }))
                                    }.padding(0.0)
                                    
                                }
                            
                            Text(settings.hideNetworth ? "***" : "\(networth)").font(.system(size: 50, design: settings.fontDesign))
                                .fontWeight(.black)
                            
                        }
                        
                        Spacer()
                    }
                }.listRowSeparator(.hidden).padding(.leading)
                                    
                VStack {
                    
                    if(!bankInfos.isEmpty && settings.showMyBanks) {
                        VStack(alignment: .leading) {
                            Text("My Banks").padding(0.0).font(.system(size: 17, design: settings.fontDesign))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    
                                    ForEach(bankInfos, id: \.self) { bankInfo in
                                        BankCardView(bankInfo: bankInfo, settings: settings)
                                    }
                                }
                            }
                        }
                        .padding(.top, 2.0).padding(.leading, 7.0)
                    }
                    
                    
                    if(settings.showUpdates ) {
                        UpdatesView(settings: settings)
                            .listRowSeparator(.hidden).padding([.horizontal, .leading])
                    }
                    
                    Spacer()
                }
                
                
            }
            
            Spacer()
            
        }.onAppear {
            
//            CurrencyRates.fetchCurrencyCodesFawazahmed0 { result in
//                print(result)
//            }

            networth = calcNetworth()
            //                        modelContext.insert(BankInfo(amount: 0, bankName: "UBA", currency: "NGN", number: 34540))
            //
            //                        modelContext.insert(BankInfo(amount: 0, bankName: "Sterling", currency: "EUR", number: 90))

        }
    
    }
}

struct HeaderMenuView: View {
    
    @ObservedObject var states: States;
    
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
                    
            Menu {
                
                
                Button("Lock") {
                    settings.isLockCodeSet = false
                }
                
                Button("Change Lock Code") {
                    settings.lockCodes = ""
                    settings.isLockCodeSet = false
                }
                
            } label: {
                Image(systemName: "ellipsis.circle").font(.system(.largeTitle, design: settings.fontDesign))
            }
                    
    }
}
