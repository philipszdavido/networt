//
//  MainView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct MainView: View {
    
    var bankInfos: [BankInfo]
    
    @ObservedObject var settings: GlobalSettings
    
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
                
                Spacer()
                                
                NavigationLink(destination: AccountTypeSelection()) {
                    Image(systemName: "plus.circle.fill").font(.system(.title, design: settings.fontDesign))
                        .padding(.trailing, 4.0)
                }
                
                HeaderMenuView()

            }.padding([.horizontal, .vertical])
            
            ScrollView {
                
                Section {
                    HStack {
                        
                        HStack(alignment: .top) {
                            
                            Text("\(getCode(curr: settings.currency))").underline(true).foregroundColor(.blue).font(.system(size: 50, design: settings.fontDesign))
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
                        .padding(.top, 2.0).padding(.leading)
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
            
            networth = calcNetworth()

        }
    
    }
}

#Preview {
    NavigationView {
        MainView(
            bankInfos: [
                BankInfo(
                    amount: 9000,
                    bankName: "United Bank of America",
                    currency: "USD",
                    number: 90
                )
            ],
            settings: GlobalSettings()
        )
    }
        .modelContainer(for: [
            BankInfo.self, Transaction.self
        ], inMemory: true)
        .environmentObject(GlobalSettings())

}
