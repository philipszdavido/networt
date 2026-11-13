//
//  OnboardingView.swift
//  networt
//

import SwiftUI

/// First launch: explain the app and pick a base currency. The PIN is set on the next screen.
struct OnboardingView: View {

    @Environment(GlobalSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.bottom, 28)

                Text("Your whole financial\npicture, in one number.")
                    .font(.largeTitle.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 20) {
                    feature("square.stack.3d.up.fill", "Everything you own and owe", "Banks, cash, stocks, crypto, property and debt.")
                    feature("arrow.left.arrow.right", "One currency", "Holdings in any currency, converted with daily rates.")
                    feature("lock.fill", "Private by design", "Stored on your device, behind a PIN and Face ID.")
                }
                .padding(.top, 36)

                Spacer()

                NavigationLink {
                    CurrencyPicker(selection: $settings.currency)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Main currency")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(settings.currency.uppercased())  \(settings.currencyName(settings.currency))")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .card()
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)

                Button("Continue") {
                    settings.hasOnboarded = true
                }
                .buttonStyle(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .screenBackground()
            .task {
                // The currency picker lists codes from the rates, which aren't cached on first launch.
                if !settings.hasRates {
                    try? await settings.refreshRates()
                }
            }
        }
    }

    func feature(_ icon: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.semibold))
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(GlobalSettings())
}
