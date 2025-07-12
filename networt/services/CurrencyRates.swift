//
//  CurrencyRates.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/11/24.
//

import Foundation

struct CurrencyRatesFawazahmed0: Codable {
    var date: String
    var data: [String: Double]
    var type: String;
}

class CurrencyRates {
        
    static func fetchCurrencyCodesFawazahmed0() async throws -> [String: String] {

        guard let url = URL(string: "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.min.json") else {

            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)

        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let currencyData = try JSONDecoder().decode([String: String].self, from: data)

        return currencyData
        
    }
    
    static func fetchCurrencyRates() async throws -> CurrencyRatesFawazahmed0 {

        struct CurrencyRates: Codable {
            var date: String
            var eur: [String: Double]
        }

        guard let url = URL(string: "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/eur.json") else {
            
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
                        
        }
        
        let (data, _) = try await URLSession.shared.data(from: url);
        
        let response = try JSONDecoder().decode(CurrencyRates.self, from: data)
        
        
        return CurrencyRatesFawazahmed0(date: response.date, data: response.eur, type: "eur")
        
    }
    
    static func convertToCurrency(from: String, to: String, amount: Double, _ settings: GlobalSettings) -> Double {
        
        let rates = settings.currencyRates
        let convertedCurrency = CurrencyRates.convertCurrency(amount: Double(amount), from: from, to: to, using: rates) ?? 0.0
        return convertedCurrency

    }
    
    static func convertToGlobalCurrency(_ bankInfo: BankInfo, _ settings: GlobalSettings) -> Double {

        let amount = bankInfo.amount;

        let currency = bankInfo.currency;
                
        let globalCurrency = settings.currency;
        
        let rates = settings.currencyRates

        let convertedCurrency = CurrencyRates.convertCurrency(amount: Double(amount), from: currency, to: globalCurrency, using: rates) ?? 0.0
                
        return convertedCurrency
    }
    
    static func convertCurrency(amount: Double, from sourceCurrency: String, to targetCurrency: String, using rates: CurrencyRatesFawazahmed0) -> Double? {
        
        // Check if the currency rates dictionary contains rates for both the source and target currencies
        guard let sourceRate = rates.data[sourceCurrency.lowercased()], let targetRate = rates.data[targetCurrency.lowercased()] else {
            // Unable to find conversion rates for source and/or target currencies
            return nil
        }
        
        // Convert the amount from the source currency to USD first using the source currency rate
        let amountInUSD = amount / sourceRate
        
        // Convert the amount from USD to the target currency using the target currency rate
        let amountInTargetCurrency = amountInUSD * targetRate
                
        return amountInTargetCurrency
    }
    
    static func getAllRates(settings: GlobalSettings) -> [(String, Double)] {
        
        
        let rates = settings.currencyRates
        
        var result: [(String, Double)] = []
        
        rates.data.forEach { (key: String, value: Double) in
            result.append((key, value))
        }
        
        return result

    }
    
    static func checkCurrencyRatesFawazahmed0IsEmpty(data: CurrencyRatesFawazahmed0) -> Bool {
        
        if data.date.isEmpty && data.data == ["": 0.0] {
            
            return true
            
        }
        
        return false
    }
    
    static func checkCurrencyCodesIsEmpty(data: [String: String]) -> Bool {
        return data == ["": ""]
    }
    
    static func getCurrencyName(code: String, data: [String: String]) -> String {
        
        guard let code = data[code] else {
            return ""
        }
                
        if code.isEmpty {
            return ""
        }
        
        return "- " + code
        
    }
    
    static func getEmptyCurrencyRatesFawazahmed0() -> CurrencyRatesFawazahmed0 {
        return CurrencyRatesFawazahmed0(date: "", data: ["" : 0.0], type: "")
    }

}

