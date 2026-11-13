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
    static let cloudContainerID = "iCloud.chidumennamdi.networth"

    let sharedModelContainer: ModelContainer

    @State private var settings: GlobalSettings

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let settings = GlobalSettings()
        let (container, syncing) = Self.makeContainer(iCloud: settings.iCloudSync)
        settings.iCloudSyncActive = syncing
        sharedModelContainer = container
        _settings = State(initialValue: settings)
    }

    /// Local and iCloud configurations share the same store file, so switching keeps the data.
    /// If iCloud can't be used (no account, or the capability isn't provisioned) the app falls back to local.
    static func makeContainer(iCloud: Bool) -> (ModelContainer, syncing: Bool) {
        let schema = Schema(allModels)

        if iCloud, let container = try? ModelContainer(for: schema, configurations: [
            ModelConfiguration(schema: schema, cloudKitDatabase: .private(cloudContainerID))
        ]) {
            LegacyMigration.run(container.mainContext)
            return (container, true)
        }

        do {
            // `.none` matters: with iCloud entitlements present, the default would sync regardless of the setting.
            let container = try ModelContainer(for: schema, configurations: [
                ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            ])
            LegacyMigration.run(container.mainContext)
            return (container, false)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !settings.hasLockCode {
                    if settings.hasOnboarded {
                        NewLockCodesView()
                    } else {
                        OnboardingView()
                    }
                } else if !settings.isUnlocked {
                    EnterLockView()
                } else {
                    RootView()
                }
            }
            .fontDesign(settings.fontDesign)
            .overlay {
                // Covers balances in the app switcher snapshot.
                if scenePhase != .active && settings.isUnlocked {
                    PrivacyCover()
                }
            }
            .onShake {
                if settings.isUnlocked {
                    withAnimation { settings.hideNetworth.toggle() }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(settings)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                settings.lock()
            }
        }
    }
}

private struct PrivacyCover: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.regularMaterial)
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
        .ignoresSafeArea()
    }
}

extension Notification.Name {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in action() }
    }
}
