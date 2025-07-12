//
//  HeaderMenuView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct HeaderMenuView: View {
        
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
                Image(systemName: "ellipsis.circle").font(.system(.title, design: settings.fontDesign))
            }
                    
    }
}

#Preview {
    HeaderMenuView()
        .modelContainer(for: [
            BankInfo.self, Transaction.self
        ], inMemory: true)
        .environmentObject(GlobalSettings())

}
