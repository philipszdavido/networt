//
//  NetworthView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/3/24.
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
        
    var body: some View {
        
        NavigationStack {
            TabView(selection: $selectedTab) {
                    
                    MainView(bankInfos: bankInfos, settings: settings, states: states).tabItem {
                        Label("Home", systemImage: "dollarsign.circle")
                    }.tag(1)
                    
                    AccountsListView(settings: settings).tabItem { Label("Accounts", systemImage: "person.3")
                    }.tag(2)
                    
                    SettingsView(settings: settings).tabItem { Label("Settings", systemImage: "gear") }.tag(3)
                    
            }
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
    
    @State private var networth: Double = 0.0;
    
    @State var toogleSheet = false
        
    func getCode(curr: String) -> String {
        return currenciesWithFlags.first { (code, symbol, name, rate) in
            code.localizedStandardContains(curr)
        }!.1
    }
    
    func calcNetworth() -> Double {
        return bankInfos.map { bankInfo in                 return CurrencyRates.convertToGlobalCurrency(bankInfo, settings)
        }.reduce(0, +)
    }
    
    var sortCurrencies: [(String, String, String, Double)] {
        
        return CurrencyRates.getAllRates(settings: self.settings).sorted { $0.1 < $1.1 }
    }
    
    var body: some View {
            VStack {

                HeaderView(states: states)
                    
                HStack {
                                        
                    HStack(alignment: .top) {
                        Text("\(getCode(curr: settings.currency))")
                            .onTapGesture {
                                toogleSheet.toggle()
                            }.sheet(isPresented: $toogleSheet, onDismiss: {
                            }) {
                                HStack {
                                    Spacer()
                                    Button("Close") {
                                        toogleSheet.toggle()
                                    }      .font(.system(size: 15))
                                        .fontWeight(.medium).padding()
                                }
                                List {
                                    ForEach(sortCurrencies, id: \.0) { flag, name, code, rate in
                                        Text("\(flag) \(name)")
                                            .font(.system(size: 15))
                                            .fontWeight(.medium).onTapGesture(perform: {
                                                settings.currency = code;
                                                networth = calcNetworth()
                                                toogleSheet.toggle()
                                        })
                                    }
                                }.listStyle(PlainListStyle())
                            }

                        Text(settings.hideNetworth ? "***" : "\(settings.currency) \(networth)")
                            
                    }.font(.system(size: 50, design: .rounded))
                        .fontWeight(.black)
                    
                    Spacer()
                }.padding(.leading, 7.0)
                
                if(!bankInfos.isEmpty && settings.showMyBanks) {
                    VStack(alignment: .leading) {
                        Text("My Banks").padding(0.0).font(.system(size: 17, design: .rounded))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {

                                ForEach(bankInfos, id: \.self) { bankInfo in
                                    BankCardView(bankInfo: bankInfo, settings: settings)
                                }
                            }
                        }
                    }.padding(.top, 2.0).padding(.leading, 7.0)
                }
                
                
                if(settings.showUpdates ) {
                    UpdatesView(settings: settings)
                }
            
            Spacer()
            }.onAppear {
                            
                networth = calcNetworth()
                
        }
    
    }
}

struct HeaderView: View {
    
    @ObservedObject var states: States;
    
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
        
        HStack {
            
            Text("My Net Worth")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .fontWeight(.black)
            
            Spacer()
            
            Menu {
                
                NavigationLink(destination: AddBankAccount()) {
                    Text("Add New Account")
                }
                
                Button("Lock") {
                    settings.isLockCodeSet = false
                }
                
                Button("Change Lock Code") {
                    settings.lockCodes = ""
                    settings.isLockCodeSet = false
                }
                
            } label: {
                Image(systemName: "ellipsis.circle").font(.system(.largeTitle, design: .rounded))
                    .padding(.trailing, 4.0)
            }
            
        }.padding(.leading, 7.0)
        
    }
}

