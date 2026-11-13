//
//  LockStore.swift
//  networt
//

import Foundation
import CryptoKit
import Security
import LocalAuthentication

/// Stores the app PIN in the Keychain as a salted SHA-256 hash.
struct LockStore {
    var service = "chidumennamdi.networth.lock"
    private let account = "pin"

    var hasPasscode: Bool {
        read() != nil
    }

    func setPasscode(_ pin: String) {
        var salt = Data(count: 16)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!) }
        write(salt + Self.hash(pin, salt: salt))
    }

    func verify(_ pin: String) -> Bool {
        guard let stored = read(), stored.count > 16 else { return false }
        let salt = stored.prefix(16)
        return Self.hash(pin, salt: salt) == stored.dropFirst(16)
    }

    func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    /// Moves a plaintext PIN saved by older versions out of UserDefaults.
    func migrateLegacyPasscode(from defaults: UserDefaults = .standard) {
        if let legacy = defaults.string(forKey: "lockCodes"), !legacy.isEmpty, !hasPasscode {
            setPasscode(legacy)
        }
        defaults.removeObject(forKey: "lockCodes")
        defaults.removeObject(forKey: "isLockCodeSet")
    }

    private static func hash(_ pin: String, salt: Data) -> Data {
        Data(SHA256.hash(data: salt + Data(pin.utf8)))
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    private func read() -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    private func write(_ data: Data) {
        clear()
        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }
}

enum Biometrics {
    static var isAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    static var label: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .touchID ? "Touch ID" : "Face ID"
    }

    static func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Enter PIN"
        return (try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your net worth")) ?? false
    }
}
