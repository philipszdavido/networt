//
//  AccountTypeSelection.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct AccountTypeSelection: View {
    
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
        List {

            NavigationLink {
                AddBankAccount(settings: settings)
            } label: {
                Text("Bank Accounts")
            }
            
            NavigationLink {
                Cash()
            } label: {
                Text("Cash")
            }

            NavigationLink {
                Investments()
            } label: {
                Text("Investments")
            }

            NavigationLink {
                Liabilities()
            } label: {
                Text("Liabilities")
            }


        }.navigationTitle("Select Account Type")
    }
}

#Preview {
    NavigationView {
        AccountTypeSelection()
    }        .environmentObject(GlobalSettings())

}
