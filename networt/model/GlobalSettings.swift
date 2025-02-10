//
//  GlobalSettings.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//
import Foundation
import Combine
import SwiftUI

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
    
    @Published var currencyRates: CurrencyRatesFawazahmed0 {
        didSet {
            // Convert CurrencyRatesResponse to Data before storing in UserDefaults
            if let encoded = try? JSONEncoder().encode(currencyRates) {
                UserDefaults.standard.set(encoded, forKey: "currencyRates")
            }
        }
    }
    
    @Published var currencyCodes: [String: String] {
        didSet {
            if let currencyCodes = try? JSONEncoder().encode(currencyCodes) {
                UserDefaults.standard.set(currencyCodes, forKey: "currencyCodes")
            }
        }
    }
    
    @Published var bankCardBgColor: Color {
        didSet {
                        
            let uiColor = UIColor(bankCardBgColor)
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
                    UserDefaults.standard.set(data, forKey: "bankCardBgColor")
            }
            
        }
    }
        
    init() {
        self.bankCardBgColor = Self.loadBgColor();
        self.currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        self.showMyBanks = UserDefaults.standard.bool(forKey: "showMyBanks")
        self.showUpdates = UserDefaults.standard.bool(forKey: "showUpdates")
        self.hideNetworth = UserDefaults.standard.bool(forKey: "hideNetworth")
        self.lockCodes = UserDefaults.standard.string(forKey: "lockCodes") ?? ""
        self.isLockCodeSet = UserDefaults.standard.bool(forKey: "isLockCodeSet")
        
        // Load currencyRates from UserDefaults
        if let savedCurrencyRatesData = UserDefaults.standard.data(forKey: "currencyRates"),
           let decodedCurrencyRates = try? JSONDecoder().decode(CurrencyRatesFawazahmed0.self, from: savedCurrencyRatesData) {
            
            if(decodedCurrencyRates.data.isEmpty) {

                self.currencyRates = CurrencyRates.getEmptyCurrencyRatesFawazahmed0()
                
            } else {
                self.currencyRates = decodedCurrencyRates
            }
                            
        } else {
            
            self.currencyRates = CurrencyRates.getEmptyCurrencyRatesFawazahmed0()
            
        }
        
        if let encodedCurrencyCodes = UserDefaults.standard.data(forKey: "currencyCodes"), let decodedCurrencyCodes = try? JSONDecoder().decode([String: String].self, from: encodedCurrencyCodes) {
            
            if (decodedCurrencyCodes.isEmpty) {
                
                self.currencyCodes = ["" : ""]
                
            } else {
                
                self.currencyCodes = decodedCurrencyCodes;
                
            }
            
        } else {
            self.currencyCodes = ["" : "" ]
        }
        
    }
    
    func loadSettings() {
        self.currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        self.showMyBanks = UserDefaults.standard.bool(forKey: "showMyBanks")
        self.showUpdates = UserDefaults.standard.bool(forKey: "showUpdates")
        self.hideNetworth = UserDefaults.standard.bool(forKey: "hideNetworth")
        self.lockCodes = UserDefaults.standard.string(forKey: "lockCodes") ?? ""
        self.isLockCodeSet = UserDefaults.standard.bool(forKey: "isLockCodeSet")
        self.bankCardBgColor = Self.loadBgColor();

        // Load currencyRates from UserDefaults
        if let savedCurrencyRatesData = UserDefaults.standard.data(forKey: "currencyRates"),
           let decodedCurrencyRates = try? JSONDecoder().decode(CurrencyRatesFawazahmed0.self, from: savedCurrencyRatesData) {

            if(decodedCurrencyRates.data.isEmpty) {

                self.currencyRates = CurrencyRates.getEmptyCurrencyRatesFawazahmed0()
                
                return
            }

            self.currencyRates = decodedCurrencyRates
            
        } else {

            self.currencyRates = CurrencyRates.getEmptyCurrencyRatesFawazahmed0()

        }
        
        // Load currencyCodes from UserDefaults
        if let encodedCurrencyCodes = UserDefaults.standard.data(forKey: "currencyCodes"), let decodedCurrencyCodes = try? JSONDecoder().decode([String: String].self, from: encodedCurrencyCodes) {
            
            if decodedCurrencyCodes.isEmpty {
                
                self.currencyCodes = ["" : ""]
                return;
                
            }
            
            self.currencyCodes = decodedCurrencyCodes;
            
        } else {
            self.currencyCodes = ["" : "" ]
        }
        
    }
    
    func loadCurrency() async throws {
        self.currencyRates = try await CurrencyRates.fetchCurrencyRates()
    }
    
    func loadCurrencycodes() async throws {
        
        self.currencyCodes = try await CurrencyRates.fetchCurrencyCodesFawazahmed0()
        
    }
    
    static func loadBgColor() -> Color {
        
        guard let data = UserDefaults.standard.data(forKey: "bankCardBgColor")
        else {
            return .blue
        }
        
        do {
            
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                return Color(uiColor)
            }
            
        } catch {
            
            print("Failed to load color:", error)
            
        }

        return .blue;
        
    }

    
}
