//
//  EnterLockView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct EnterLockView: View {

    @Environment(GlobalSettings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase

    @State private var failures = 0

    var canUseBiometrics: Bool {
        settings.useBiometrics && Biometrics.isAvailable
    }

    var body: some View {
        PinEntryView(
            title: "Enter PIN",
            message: failures > 0 ? "Incorrect PIN. Try again." : "Unlock to see your net worth",
            failures: failures
        ) { pin in
            if !settings.unlock(with: pin) {
                failures += 1
            }
        } accessory: {
            if canUseBiometrics {
                Button {
                    Task { await unlockWithBiometrics() }
                } label: {
                    Label("Use \(Biometrics.label)", systemImage: Biometrics.label == "Touch ID" ? "touchid" : "faceid")
                        .font(.body.weight(.medium))
                }
            }
        }
        .task {
            await unlockWithBiometrics()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // The biometric prompt itself toggles .inactive/.active, so only retry on a real return to the app.
            if oldPhase == .background && newPhase != .background {
                Task { await unlockWithBiometrics() }
            }
        }
    }

    func unlockWithBiometrics() async {
        guard canUseBiometrics, scenePhase != .background else { return }
        if await Biometrics.authenticate() {
            settings.isUnlocked = true
        }
    }
}

#Preview {
    EnterLockView()
        .environment(GlobalSettings())
}
