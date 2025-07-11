//
//  TestWelcomeView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

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
