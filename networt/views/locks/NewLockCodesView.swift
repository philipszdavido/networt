//
//  NewLockCodesView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct NewLockCodesView: View {

    @Environment(GlobalSettings.self) private var settings

    @State private var firstPin: String? = nil
    @State private var failures = 0

    var body: some View {
        PinEntryView(
            title: firstPin == nil ? "Create a PIN" : "Confirm your PIN",
            message: firstPin != nil ? "Enter it once more" : (failures > 0 ? "PINs didn't match. Start again." : "You'll use it to open the app"),
            failures: failures
        ) { pin in
            guard let firstPin else {
                self.firstPin = pin
                return
            }

            if firstPin == pin {
                settings.setPasscode(pin)
                if Biometrics.isAvailable {
                    settings.useBiometrics = true
                }
            } else {
                self.firstPin = nil
                failures += 1
            }
        }
    }
}

#Preview {
    NewLockCodesView()
        .environment(GlobalSettings())
}
