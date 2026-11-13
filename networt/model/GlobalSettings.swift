//
//  GlobalSettings.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//
import Foundation
import SwiftUI

/// App-wide preferences. Each stored property saves itself to UserDefaults when it changes.
@Observable
final class GlobalSettings {

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored let lockStore: LockStore

    // MARK: - Display

    var currency: String {
        didSet { defaults.set(currency, forKey: "currency") }
    }

    var hideNetworth: Bool {
        didSet {
            defaults.set(hideNetworth, forKey: "hideNetworth")
            WidgetBridge.setHidden(hideNetworth)
        }
    }

    /// Shows recent bank transactions on Home.
    var showUpdates: Bool {
        didSet { defaults.set(showUpdates, forKey: "showUpdates") }
    }

    var fontDesign: Font.Design {
        didSet { UserDefaults.saveFontDesign(fontDesign) }
    }

    // MARK: - Lock

    /// Whether a PIN exists in the Keychain. The PIN itself never touches UserDefaults.
    private(set) var hasLockCode: Bool

    /// Held in memory only, so every launch (and every return from the background) starts locked.
    var isUnlocked = false

    var useBiometrics: Bool {
        didSet { defaults.set(useBiometrics, forKey: "useBiometrics") }
    }

    var hasOnboarded: Bool {
        didSet { defaults.set(hasOnboarded, forKey: "hasOnboarded") }
    }

    // MARK: - Features

    var remindersEnabled: Bool {
        didSet { defaults.set(remindersEnabled, forKey: "remindersEnabled") }
    }

    /// Read when the model container is created, so a change applies on the next launch.
    var iCloudSync: Bool {
        didSet { defaults.set(iCloudSync, forKey: Self.iCloudSyncKey) }
    }

    /// Whether the running container was created with iCloud sync on.
    @ObservationIgnored var iCloudSyncActive = false

    static let iCloudSyncKey = "iCloudSync"

    /// Target net worth in the base currency. 0 means no goal.
    var netWorthGoal: Double {
        didSet { defaults.set(netWorthGoal, forKey: "netWorthGoal") }
    }

    /// Target for bank + cash in the base currency. 0 means no goal.
    var emergencyFundGoal: Double {
        didSet { defaults.set(emergencyFundGoal, forKey: "emergencyFundGoal") }
    }

    // MARK: - Rates

    var currencyRates: CurrencyRatesFawazahmed0 {
        didSet {
            if let encoded = try? JSONEncoder().encode(currencyRates) {
                defaults.set(encoded, forKey: "currencyRates")
            }
        }
    }

    var currencyCodes: [String: String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(currencyCodes) {
                defaults.set(encoded, forKey: "currencyCodes")
            }
        }
    }

    var ratesFetchedAt: Date? {
        didSet { defaults.set(ratesFetchedAt, forKey: "ratesFetchedAt") }
    }

    init(lockStore: LockStore = LockStore(), defaults: UserDefaults = .standard) {
        lockStore.migrateLegacyPasscode(from: defaults)
        self.lockStore = lockStore
        self.defaults = defaults
        self.hasLockCode = lockStore.hasPasscode

        self.currency = defaults.string(forKey: "currency") ?? "USD"
        self.hideNetworth = defaults.bool(forKey: "hideNetworth")
        self.showUpdates = defaults.object(forKey: "showUpdates") as? Bool ?? true
        self.fontDesign = UserDefaults.loadFontDesign()
        self.useBiometrics = defaults.bool(forKey: "useBiometrics")
        self.hasOnboarded = defaults.bool(forKey: "hasOnboarded") || lockStore.hasPasscode
        self.remindersEnabled = defaults.bool(forKey: "remindersEnabled")
        self.iCloudSync = defaults.bool(forKey: Self.iCloudSyncKey)
        self.netWorthGoal = defaults.double(forKey: "netWorthGoal")
        self.emergencyFundGoal = defaults.double(forKey: "emergencyFundGoal")
        self.ratesFetchedAt = defaults.object(forKey: "ratesFetchedAt") as? Date

        if let data = defaults.data(forKey: "currencyRates"),
           let decoded = try? JSONDecoder().decode(CurrencyRatesFawazahmed0.self, from: data),
           !decoded.data.isEmpty {
            self.currencyRates = decoded
        } else {
            self.currencyRates = CurrencyRates.getEmptyCurrencyRatesFawazahmed0()
        }

        if let data = defaults.data(forKey: "currencyCodes"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data),
           !decoded.isEmpty {
            self.currencyCodes = decoded
        } else {
            self.currencyCodes = ["": ""]
        }
    }

    // MARK: - Lock

    func setPasscode(_ pin: String) {
        lockStore.setPasscode(pin)
        hasLockCode = true
        isUnlocked = true
    }

    /// Returns false when the PIN is wrong.
    func unlock(with pin: String) -> Bool {
        guard lockStore.verify(pin) else { return false }
        isUnlocked = true
        return true
    }

    func lock() {
        isUnlocked = false
    }

    /// Removes the current PIN so the user is asked to create a new one. Only reachable while unlocked.
    func resetPasscode() {
        lockStore.clear()
        hasLockCode = false
    }

    // MARK: - Rates

    var hasRates: Bool {
        !CurrencyRates.checkCurrencyRatesFawazahmed0IsEmpty(data: currencyRates) && !CurrencyRates.checkCurrencyCodesIsEmpty(data: currencyCodes)
    }

    var ratesAreStale: Bool {
        guard let ratesFetchedAt else { return true }
        return Date.now.timeIntervalSince(ratesFetchedAt) > 12 * 60 * 60
    }

    var ratesDate: Date? {
        currencyRates.date.isEmpty ? nil : Time.dateFromString(currencyRates.date)
    }

    @MainActor
    func refreshRates() async throws {
        currencyRates = try await CurrencyRates.fetchCurrencyRates()
        ratesFetchedAt = .now
        currencyCodes = try await CurrencyRates.fetchCurrencyCodesFawazahmed0()
    }

    /// Refreshes rates when they are older than 12 hours. Failures keep the cached rates.
    @MainActor
    func refreshRatesIfStale() async {
        if ratesAreStale {
            try? await refreshRates()
        }
    }

    func currencyName(_ code: String) -> String {
        currencyCodes[code.lowercased()] ?? ""
    }

    /// Lowercase currency codes that have a rate, sorted.
    var availableCurrencies: [String] {
        currencyRates.data.keys.filter { !$0.isEmpty }.sorted()
    }
}
