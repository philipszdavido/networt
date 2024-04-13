//
//  CurrencyRates.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/11/24.
//

import Foundation

let currenciesWithFlags: [(String, String, String, Double)] = [
    ("USD", "🇺🇸", "United States Dollar", 1.0),
    ("EUR", "🇪🇺", "Euro", 0.92),
    ("GBP", "🇬🇧", "British Pound", 0.79),
    ("JPY", "🇯🇵", "Japanese Yen", 109.64),
    ("AUD", "🇦🇺", "Australian Dollar", 1.33),
    ("CAD", "🇨🇦", "Canadian Dollar", 1.26),
    ("CHF", "🇨🇭", "Swiss Franc", 0.94),
    ("CNY", "🇨🇳", "Chinese Yuan", 6.46),
    ("SEK", "🇸🇪", "Swedish Krona", 8.45),
    ("NZD", "🇳🇿", "New Zealand Dollar", 1.43),
    ("KRW", "🇰🇷", "South Korean Won", 1168.50),
    ("NOK", "🇳🇴", "Norwegian Krone", 8.63),
    ("INR", "🇮🇳", "Indian Rupee", 75.14),
    ("HKD", "🇭🇰", "Hong Kong Dollar", 7.77),
    ("SGD", "🇸🇬", "Singapore Dollar", 1.34),
    ("MXN", "🇲🇽", "Mexican Peso", 20.03),
    ("BRL", "🇧🇷", "Brazilian Real", 5.34),
    ("RUB", "🇷🇺", "Russian Ruble", 76.70),
    ("TRY", "🇹🇷", "Turkish Lira", 8.18),
    ("ZAR", "🇿🇦", "South African Rand", 14.97),
    ("AED", "🇦🇪", "UAE Dirham", 3.67),
    ("SAR", "🇸🇦", "Saudi Riyal", 3.75),
    ("QAR", "🇶🇦", "Qatari Riyal", 3.64),
    ("KWD", "🇰🇼", "Kuwaiti Dinar", 0.30),
    ("PHP", "🇵🇭", "Philippine Peso", 48.15),
    ("THB", "🇹🇭", "Thai Baht", 31.19),
    ("MYR", "🇲🇾", "Malaysian Ringgit", 4.16),
    ("IDR", "🇮🇩", "Indonesian Rupiah", 14392.43),
    ("ARS", "🇦🇷", "Argentine Peso", 98.73),
    ("CLP", "🇨🇱", "Chilean Peso", 799.80),
    ("COP", "🇨🇴", "Colombian Peso", 3977.50),
    ("EGP", "🇪🇬", "Egyptian Pound", 15.67),
    ("ILS", "🇮🇱", "Israeli Shekel", 3.24),
    ("PKR", "🇵🇰", "Pakistani Rupee", 176.72),
    ("UAH", "🇺🇦", "Ukrainian Hryvnia", 27.76),
    ("VND", "🇻🇳", "Vietnamese Dong", 23045.50),
    ("BDT", "🇧🇩", "Bangladeshi Taka", 85.05),
    ("NGN", "🇳🇬", "Nigerian Naira", 411.58),
    ("KES", "🇰🇪", "Kenyan Shilling", 113.86),
    ("UGX", "🇺🇬", "Ugandan Shilling", 3541.00),
    ("GHS", "🇬🇭", "Ghanaian Cedi", 9.69),
    ("TZS", "🇹🇿", "Tanzanian Shilling", 2327.50),
    ("RWF", "🇷🇼", "Rwandan Franc", 1012.10),
    ("ZMW", "🇿🇲", "Zambian Kwacha", 22.69),
    ("MAD", "🇲🇦", "Moroccan Dirham", 9.49),
    ("DZD", "🇩🇿", "Algerian Dinar", 134.04),
    ("TND", "🇹🇳", "Tunisian Dinar", 2.95),
    ("LYD", "🇱🇾", "Libyan Dinar", 4.53),
    ("MUR", "🇲🇺", "Mauritian Rupee", 43.50),
    ("ETB", "🇪🇹", "Ethiopian Birr", 47.03),
    ("GEL", "🇬🇪", "Georgian Lari", 3.31),
    ("BYN", "🇧🇾", "Belarusian Ruble", 2.54),
    ("CRC", "🇨🇷", "Costa Rican Colon", 619.71),
    ("UYU", "🇺🇾", "Uruguayan Peso", 43.92),
    ("PYG", "🇵🇾", "Paraguayan Guarani", 7055.00),
    ("BHD", "🇧🇭", "Bahraini Dinar", 0.38),
    ("OMR", "🇴🇲", "Omani Rial", 0.38),
    ("JOD", "🇯🇴", "Jordanian Dinar", 0.71),
    ("LBP", "🇱🇧", "Lebanese Pound", 1507.50),
    ("SYP", "🇸🇾", "Syrian Pound", 2567.50),
    ("MVR", "🇲🇻", "Maldivian Rufiyaa", 15.42),
    ("MZN", "🇲🇿", "Mozambican Metical", 75.29),
    ("XOF", "🇸🇳", "West African CFA Franc", 540.00),
    ("XAF", "🇨🇫", "Central African CFA Franc", 540.00),
    ("GIP", "🇬🇮", "Gibraltar Pound", 0.72),
    ("FKP", "🇫🇰", "Falkland Islands Pound", 0.72),
    ("XCD", "🇦🇮", "East Caribbean Dollar", 2.70),
    ("BMD", "🇧🇲", "Bermudian Dollar", 1.00),
    ("SHP", "🇸🇭", "Saint Helena Pound", 0.72),
    ("AWG", "🇦🇼", "Aruban Florin", 1.79),
    ("BZD", "🇧🇿", "Belize Dollar", 2.02),
    ("BBD", "🇧🇧", "Barbadian Dollar", 2.00),
    ("BND", "🇧🇳", "Brunei Dollar", 1.34),
    ("BSD", "🇧🇸", "Bahamian Dollar", 1.00),
    ("BWP", "🇧🇼", "Botswana Pula", 11.07),
    ("KYD", "🇰🇾", "Cayman Islands Dollar", 0.82),
    ("FJD", "🇫🇯", "Fijian Dollar", 2.06),
    ("GYD", "🇬🇾", "Guyanese Dollar", 209.47),
    ("JMD", "🇯🇲", "Jamaican Dollar", 152.71),
    ("LAK", "🇱🇦", "Lao Kip", 9907.50),
    ("LRD", "🇱🇷", "Liberian Dollar", 175.00),
    ("MOP", "🇲🇴", "Macanese Pataca", 7.98)
]

struct CurrencyRatesResponse: Codable {
    var data: [String: Double]
}

let freecurrencyapiCurrencis = [
    ("EUR", "Euro"),
    ("USD", "US Dollar"),
    ("JPY", "Japanese Yen"),
    ("BGN", "Bulgarian Lev"),
    ("CZK", "Czech Republic Koruna"),
    ("DKK", "Danish Krone"),
    ("GBP", "British Pound Sterling"),
    ("HUF", "Hungarian Forint"),
    ("PLN", "Polish Zloty"),
    ("RON", "Romanian Leu"),
    ("SEK", "Swedish Krona"),
    ("CHF", "Swiss Franc"),
    ("ISK", "Icelandic Króna"),
    ("NOK", "Norwegian Krone"),
    ("HRK", "Croatian Kuna"),
    ("RUB", "Russian Ruble"),
    ("TRY", "Turkish Lira"),
    ("AUD", "Australian Dollar"),
    ("BRL", "Brazilian Real"),
    ("CAD", "Canadian Dollar"),
    ("CNY", "Chinese Yuan"),
    ("HKD", "Hong Kong Dollar"),
    ("IDR", "Indonesian Rupiah"),
    ("ILS", "Israeli New Sheqel"),
    ("INR", "Indian Rupee"),
    ("KRW", "South Korean Won"),
    ("MXN", "Mexican Peso"),
    ("MYR", "Malaysian Ringgit"),
    ("NZD", "New Zealand Dollar"),
    ("PHP", "Philippine Peso"),
    ("SGD", "Singapore Dollar"),
    ("THB", "Thai Baht"),
    ("ZAR", "South African Rand")
]


class CurrencyRates {
    
    static let defaultRates = [
        "THB": 36.5952441393,
        "GBP": 0.8031401012,
        "MYR": 4.7696107882,
        "NZD": 1.6839903081,
        "MXN": 16.6307418092,
        "USD": 1.0,
        "CHF": 0.9141301241,
        "PHP": 56.604807645,
        "KRW": 1378.0310104253,
        "INR": 83.501071702,
        "NOK": 10.8986417408,
        "ZAR": 18.8333636192,
        "SGD": 1.3600101462,
        "CNY": 7.2353712409,
        "JPY": 153.2989265335,
        "CAD": 1.3772302746,
        "ILS": 3.7721307502,
        "IDR": 15826.235216479,
        "TRY": 32.3506447649,
        "SEK": 10.8859516474,
        "EUR": 0.9390801563,
        "RUB": 93.2937864971,
        "BRL": 5.1284106751,
        "HKD": 7.8360815249,
        "AUD": 1.5468401859,
        "NGN": 1200.50,
    ]
    
    static func fetchRates() async throws -> CurrencyRatesResponse {
        let currenciesParam = currenciesWithFlags.map { currency in
            currency.0
        }.filter({ currency in
            freecurrencyapiCurrencis.contains { $0.0 == currency }
        }).joined(separator: "%2C")
                
        let url = URL(string: "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_vUfAbCn8XzuyUo097nqQKh0oYnsaj9uzUqacZVwP&currencies=" + currenciesParam)
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        
        var dataResponse: CurrencyRatesResponse?
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            let decoded = try JSONDecoder().decode(CurrencyRatesResponse.self, from: data)

            dataResponse = decoded

            return decoded

        } catch {
            print(error)
        }
        
        return dataResponse!
    }
    
    static func convertToGlobalCurrency(_ bankInfo: BankInfo, _ settings: GlobalSettings) -> Double {
        let amount = bankInfo.amount;
        let currency = bankInfo.currency;
                
        let globalCurrency = settings.currency;
        
        var rates = settings.currencyRates

        currenciesWithFlags.forEach { (code, flag, name, rate) in
            if rates.data[code] == nil {
                rates.data[code] = rate
            }
        }

        let a = CurrencyRates.convertCurrency(amount: Double(amount), from: currency, to: globalCurrency, using: rates) ?? 0.0
                
        return a
    }
    
    static func convertCurrency(amount: Double, from sourceCurrency: String, to targetCurrency: String, using rates: CurrencyRatesResponse) -> Double? {
        // Check if the currency rates dictionary contains rates for both the source and target currencies
        guard let sourceRate = rates.data[sourceCurrency], let targetRate = rates.data[targetCurrency] else {
            // Unable to find conversion rates for source and/or target currencies
            return nil
        }
        
        // Convert the amount from the source currency to USD first using the source currency rate
        let amountInUSD = amount / sourceRate
        
        // Convert the amount from USD to the target currency using the target currency rate
        let amountInTargetCurrency = amountInUSD * targetRate
        
        return amountInTargetCurrency
    }
    
    static func getAllRates(settings: GlobalSettings) -> [(String, String, String, Double)] {
        
        
        var rates = settings.currencyRates
        
        var result: [(String, String, String,Double)] = []

        currenciesWithFlags.forEach { (code, flag, name, rate) in
                        
            if rates.data[code] == nil {
                rates.data[code] = rate
            }
            
            result.append((flag, name, code, rates.data[code]!))
        }
        
        return result

    }

}

