//
//  SummaryView.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import SwiftUI
import Charts
import SwiftData

// MARK: - Account Model
struct Account: Identifiable {
    let id = UUID()
    var name: String
    var type: AccountType
    var balance: Double
    var currency: String
}

enum AccountType: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case bank = "Bank"
    case cash = "Cash"
    case investment = "Investment"
    case liability = "Liability"
}

class SummaryViewModel: ObservableObject {

    @Published var accounts: [Account] = []
    var settings: GlobalSettings

    var totalAssets: Double {
        accounts.filter { $0.type != .liability }.map { $0.balance }.reduce(0, +)
    }

    var totalLiabilities: Double {
        accounts.filter { $0.type == .liability }.map { abs($0.balance) }.reduce(0, +)
    }

    var netWorth: Double {
        totalAssets - totalLiabilities
    }

    func fetchAllBanks(bankInfos: [BankInfo]) {
        
        let amount = bankInfos.map { BankInfo in
            let a = CurrencyRates.convertCurrency(
                amount: Double(BankInfo.amount),
                from: BankInfo.currency,
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0
            
            return a
            
        }.reduce(0.0, +)
        
        let account = Account(
            name: "Bank",
            type: AccountType.bank,
            balance: Double(amount),
            currency: settings.currency
        )
        
        accounts += [account]
        
    }
    
    func fetchAllCash(cash: [Cash]) {
        
        let amount = cash.map { Cash in
            
            let a = CurrencyRates.convertCurrency(
                amount: Double(Cash.amount),
                from: Cash.currency,
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0

            return a
        }.reduce(0.0, { next, el in
            next + el
        })
        
        accounts += [Account(name: "Cash", type: .cash, balance: amount, currency: settings.currency)]
        
    }
    
    func fetchAllInvestments(
        stocks: [Stock],
        properties: [Property],
        coinHoldings: [CoinHolding]
    ) {
        
        // stocks
        let totalStocks = stocks.map { Stock in
            
            let a = CurrencyRates.convertCurrency(
                amount: Double(Double(Stock.price * Stock.quantity)),
                from: "USD",
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0
            
            return a

        }.reduce(0.0, +)
        
        // properties
        let totalProperties = properties.map { Property in
         
            let a = CurrencyRates.convertCurrency(
                amount: Double(Property.marketValue),
                from: Property.currency,
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0
            
            return a

        }.reduce(0.0, +)
        
        // coin holdings
        let totalCoinHoldings = coinHoldings.map { CoinHolding in
            
            let a = CurrencyRates.convertCurrency(
                amount: Double(CoinHolding.totalValue),
                from: "USD",
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0
            
            return a

        }.reduce(0.0, +)
        
        let totalInvestments = totalStocks + totalProperties + totalCoinHoldings
        
        accounts += [
            Account(
                name: "Investments",
                type: .investment,
                balance: totalInvestments,
                currency: settings.currency
            )
        ]
    }
    
    func fetchAllLiabilities(liabilities: [Liability]) {
        
        let totalLiabilities = liabilities.map { Liability in
            
            let a = CurrencyRates.convertCurrency(
                amount: Double(Liability.balance),
                from: Liability.currency,
                to: settings.currency,
                using: settings.currencyRates
            ) ?? 0.0
            
            return a

        }.reduce(0.0, +)
        
        accounts += [
            Account(
                name: "Liability",
                type: .liability,
                balance: totalLiabilities,
                currency: settings.currency
            )
        ]
    }
    
    init(settings: GlobalSettings) {
        self.settings = settings
    }
            
    func sumAll(
            settings: GlobalSettings,
            bankInfos: [BankInfo],
            cash: [Cash],
            stocks: [Stock],
            properties: [Property],
            liabilities: [Liability],
            coinHoldings: [CoinHolding]
        ) {
            fetchAllBanks(bankInfos: bankInfos)
            fetchAllCash(cash: cash)
            fetchAllInvestments(
                stocks: stocks,
                properties: properties,
                coinHoldings: coinHoldings
            )
            fetchAllLiabilities(liabilities: liabilities)
        }
    
}

struct SummaryView: View {
    
    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.modelContext) var modelContext
    
    @StateObject private var viewModel: SummaryViewModel
    
    @Query var bankInfos: [BankInfo]
    @Query var cash: [Cash]
    @Query var stocks: [Stock]
    @Query var properties: [Property]
    @Query var liabilities: [Liability]
    @Query var coinHoldings: [CoinHolding]

    var body: some View {
        
        VStack {
            
            HStack {
                Text("My Net Worth")
                    .font(.system(.largeTitle, design: settings.fontDesign))
                    .bold()
                    .fontWeight(.black)

                Spacer()
                NavigationLink(destination: AccountTypeSelection()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(.title, design: settings.fontDesign))
                        .padding(.trailing, 4.0)
                }
                HeaderMenuView()
                
            }.padding(.horizontal)
            
            List {
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Assets")
                        Spacer()
                        Text(viewModel.totalAssets, format: .currency(code: settings.currency))
                    }
                    HStack {
                        Text("Liabilities")
                        Spacer()
                        Text(viewModel.totalLiabilities, format: .currency(code: settings.currency))
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Net Worth")
                        Spacer()
                        Text(viewModel.netWorth, format: .currency(code: settings.currency))
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.netWorth >= 0 ? .green : .red)
                    }
                }
                
                Section(header: Text("Accounts")) {
                    ForEach(viewModel.accounts) { account in
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            HStack {
                                Text(account.type.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(account.balance, format: .currency(code: settings.currency))
                                
                            }
                        }
                    }
                }
                
                
                Chart {
                    ForEach($viewModel.accounts) { account in
                        SectorMark(
                            angle:
                                    .value(
                                        "Amount",
                                        account.balance.wrappedValue
                                    ),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.0
                            
                        )
                        .foregroundStyle(
                            by:
                                    .value(
                                        "Type",
                                        account.type.id
                                    )
                        )
                    }
                }.padding()
                
            }
            .onAppear {
                viewModel.accounts = []
                viewModel.sumAll(
                    settings: settings,
                    bankInfos: bankInfos,
                    cash: cash,
                    stocks: stocks,
                    properties: properties,
                    liabilities: liabilities,
                    coinHoldings: coinHoldings
                )
            }
        }
        
    }
    
    init(settings: GlobalSettings) {
        _viewModel = StateObject(
            wrappedValue: SummaryViewModel(
                settings: settings
            )
        )
    }
}

#Preview {
    SummaryView(settings: GlobalSettings())
        .environmentObject(GlobalSettings())
        .modelContainer(for: allModels, inMemory: true)
}



#Preview {
    
    let settings = GlobalSettings()
    
    NavigationStack {
        TabView {
            
            NavigationLink(destination: AccountTypeSelection()) {
                Image(systemName: "plus.circle.fill").font(.system(.largeTitle, design: settings.fontDesign))
                    .padding(.trailing, 4.0)
            }
            .tabItem {
                Label("Home", systemImage: "dollarsign.circle")
            }.tag(1)
            
            SummaryView(settings: settings)
                .tabItem {
                    Label("Summary", systemImage: "widget.small")
                }.tag(2)
            
        }
    }.environmentObject(settings)
        .modelContainer(for: allModels, inMemory: true)
}
