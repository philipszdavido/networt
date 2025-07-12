//
//  TestWelcomeView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Charts

struct TestWelcomeView: View {
    
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
        Group {
            
            if(settings.lockCodes.isEmpty) {
                
                LockView(newLockCode: true)
                
            } else {
                
                if(!settings.isLockCodeSet) {
                    LockView(newLockCode: false )
                } else {
                    NetworthView()
                }
            }
            
        }
        .modelContainer(networtApp().sharedModelContainer)
        .environmentObject(settings)
    }
}

#Preview {
    TestWelcomeView()
        .environmentObject(GlobalSettings())
}

// MARK: - ViewModel
class FinanceViewModel: ObservableObject {
    @Published var accounts: [Account] = [
        Account(name: "Checking", type: .bank, balance: 4000, currency: "USD"),
        Account(name: "Wallet", type: .cash, balance: 500, currency: "USD"),
        Account(name: "Stocks", type: .investment, balance: 8000, currency: "USD"),
        Account(name: "Credit Card", type: .liability, balance: -3000, currency: "USD")
    ]

    var totalAssets: Double {
        accounts.filter { $0.type != .liability }.map { $0.balance }.reduce(0, +)
    }

    var totalLiabilities: Double {
        accounts.filter { $0.type == .liability }.map { abs($0.balance) }.reduce(0, +)
    }

    var netWorth: Double {
        totalAssets - totalLiabilities
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @StateObject private var viewModel = FinanceViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Assets")
                        Spacer()
                        Text("$\(viewModel.totalAssets, specifier: "%.2f")")
                    }
                    HStack {
                        Text("Liabilities")
                        Spacer()
                        Text("-$\(viewModel.totalLiabilities, specifier: "%.2f")")
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Net Worth")
                        Spacer()
                        Text("$\(viewModel.netWorth, specifier: "%.2f")")
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
                                Text("\(account.currency) \(account.balance, specifier: "%.2f")")
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
            .navigationTitle("My Net Worth")
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(GlobalSettings())
    }
}
