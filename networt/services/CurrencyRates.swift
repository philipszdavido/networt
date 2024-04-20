//
//  CurrencyRates.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/11/24.
//

import Foundation

struct CurrencyRatesFawazahmed0: Codable {
    var date: String
    var usd: [String: Double]
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
        
        guard let url = URL(string: "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json") else {
            
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
                        
        }
        
        let (data, _) = try await URLSession.shared.data(from: url);
        
        let response = try JSONDecoder().decode(CurrencyRatesFawazahmed0.self, from: data)

        return response;
        
    }
    
    static func convertToGlobalCurrency(_ bankInfo: BankInfo, _ settings: GlobalSettings) -> Double {

        let amount = bankInfo.amount;

        let currency = bankInfo.currency;
                
        let globalCurrency = settings.currency;
        
        let rates = settings.currencyRates

        let a = CurrencyRates.convertCurrency(amount: Double(amount), from: currency, to: globalCurrency, using: rates) ?? 0.0
                
        return a
    }
    
    static func convertCurrency(amount: Double, from sourceCurrency: String, to targetCurrency: String, using rates: CurrencyRatesFawazahmed0) -> Double? {
        
        // Check if the currency rates dictionary contains rates for both the source and target currencies
        guard let sourceRate = rates.usd[sourceCurrency], let targetRate = rates.usd[targetCurrency] else {
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
        
        rates.usd.forEach { (key: String, value: Double) in
            result.append((key, value))
        }
        
        return result

    }
    
    static func checkCurrencyRatesFawazahmed0IsEmpty(data: CurrencyRatesFawazahmed0) -> Bool {
        
        if data.date.isEmpty && data.usd == ["": 0.0] {
            
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
        
//        print(code)
        
        if code.isEmpty {
            return ""
        }
        
        return " - " + code
        
    }

}

