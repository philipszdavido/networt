//
//  GlobalSettings.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//
import Foundation
import Combine

class GlobalSettings: ObservableObject {
    
    @Published var currency: String {
        didSet {
            UserDefaults.standard.set(currency, forKey: "currency")
        }
    }
    
    @Published var showMyBanks: Bool {
        didSet {
            UserDefaults.standard.set(showMyBanks, forKey: "showMyBanks")
        }
    }
    
    @Published var showUpdates: Bool {
        didSet {
            UserDefaults.standard.set(showUpdates, forKey: "showUpdates")
        }
    }
    
    @Published var hideNetworth: Bool {
        didSet {
            UserDefaults.standard.set(hideNetworth, forKey: "hideNetworth")
        }
    }
    
    @Published var lockCodes: String {
        didSet {
            UserDefaults.standard.set(lockCodes, forKey: "lockCodes")
        }
    }
    
    @Published var isLockCodeSet: Bool {
        didSet {
            UserDefaults.standard.set(isLockCodeSet, forKey: "isLockCodeSet")
        }
    }
    
    init() {
        self.currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        self.showMyBanks = UserDefaults.standard.bool(forKey: "showMyBanks")
        self.showUpdates = UserDefaults.standard.bool(forKey: "showUpdates")
        self.hideNetworth = UserDefaults.standard.bool(forKey: "hideNetworth")
        self.lockCodes = UserDefaults.standard.string(forKey: "lockCodes") ?? ""
        self.isLockCodeSet = UserDefaults.standard.bool(forKey: "isLockCodeSet") 
    }
    
    func loadSettings() {
        self.currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        self.showMyBanks = UserDefaults.standard.bool(forKey: "showMyBanks")
        self.showUpdates = UserDefaults.standard.bool(forKey: "showUpdates")
        self.hideNetworth = UserDefaults.standard.bool(forKey: "hideNetworth")
        self.lockCodes = UserDefaults.standard.string(forKey: "lockCodes") ?? ""
        self.isLockCodeSet = UserDefaults.standard.bool(forKey: "isLockCodeSet") 
    }
}
