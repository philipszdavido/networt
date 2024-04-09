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
    
    @State private var networth: Int = 0;
    
    var body: some View {
        if(states.addNewAccount) {
            AddBankAccount(states: states)
        }
        else{
            VStack {
                HeaderView(states: states)
                
                HStack {
                    
                    Text(settings.hideNetworth ? "***" : "\(settings.currency) \(networth)").font(.system(size: 50, design: .rounded))
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
            networth = bankInfos.map { bankInfo in                 return bankInfo.amount
            }.reduce(0, +)
        }
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
                NavigationLink(destination: AddBankAccount(states: states)) {
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

