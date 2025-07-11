//
//  networtApp.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/3/24.
//

import SwiftUI
import SwiftData

@main
struct networtApp: App {
    public var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BankInfo.self,
            Transaction.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var settings =  GlobalSettings()

    var body: some Scene {
        WindowGroup {
            
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
        .modelContainer(sharedModelContainer)
        .environmentObject(settings)
    }
}
