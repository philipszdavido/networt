//
//  AddBankAccount.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import SwiftUI
import SwiftData

let currencies = [
    "USD", "EUR", "JPY", "GBP", "AUD", "CAD", "CHF", "CNY", "SEK", "NZD",
    "KRW", "SGD", "NOK", "MXN", "INR", "RUB", "ZAR", "HKD", "BRL", "TRY",
    "TWD", "DKK", "PLN", "THB", "IDR", "HUF", "CZK", "ILS", "CLP", "PHP",
    "AED", "COP", "SAR", "MYR", "RON", "CNY", "NGN", "ARS", "COP", "PEN",
    "KWD", "QAR", "IQD", "BDT", "CZK", "HUF", "PKR", "XAU", "VND", "CNY"
]

let currenciesWithFlags: [(String, String)] = [
    ("USD", "🇺🇸"), // United States Dollar
    ("EUR", "🇪🇺"), // Euro
    ("GBP", "🇬🇧"), // British Pound
    ("JPY", "🇯🇵"), // Japanese Yen
    ("AUD", "🇦🇺"), // Australian Dollar
    ("CAD", "🇨🇦"), // Canadian Dollar
    ("CHF", "🇨🇭"), // Swiss Franc
    ("CNY", "🇨🇳"), // Chinese Yuan
    ("SEK", "🇸🇪"), // Swedish Krona
    ("NZD", "🇳🇿"), // New Zealand Dollar
    ("KRW", "🇰🇷"), // South Korean Won
    ("NOK", "🇳🇴"), // Norwegian Krone
    ("INR", "🇮🇳"), // Indian Rupee
    ("HKD", "🇭🇰"), // Hong Kong Dollar
    ("SGD", "🇸🇬"), // Singapore Dollar
    ("MXN", "🇲🇽"), // Mexican Peso
    ("BRL", "🇧🇷"), // Brazilian Real
    ("RUB", "🇷🇺"), // Russian Ruble
    ("TRY", "🇹🇷"), // Turkish Lira
    ("ZAR", "🇿🇦"), // South African Rand
    ("AED", "🇦🇪"), // UAE Dirham
    ("SAR", "🇸🇦"), // Saudi Riyal
    ("QAR", "🇶🇦"), // Qatari Riyal
    ("KWD", "🇰🇼"), // Kuwaiti Dinar
    ("PHP", "🇵🇭"), // Philippine Peso
    ("THB", "🇹🇭"), // Thai Baht
    ("MYR", "🇲🇾"), // Malaysian Ringgit
    ("IDR", "🇮🇩"), // Indonesian Rupiah
    ("ARS", "🇦🇷"), // Argentine Peso
    ("CLP", "🇨🇱"), // Chilean Peso
    ("COP", "🇨🇴"), // Colombian Peso
    ("EGP", "🇪🇬"), // Egyptian Pound
    ("ILS", "🇮🇱"), // Israeli Shekel
    ("PKR", "🇵🇰"), // Pakistani Rupee
    ("UAH", "🇺🇦"), // Ukrainian Hryvnia
    ("VND", "🇻🇳"), // Vietnamese Dong
    ("BDT", "🇧🇩"), // Bangladeshi Taka
    ("NGN", "🇳🇬"), // Nigerian Naira
    ("KES", "🇰🇪"), // Kenyan Shilling
    ("UGX", "🇺🇬"), // Ugandan Shilling
    ("GHS", "🇬🇭"), // Ghanaian Cedi
    ("TZS", "🇹🇿"), // Tanzanian Shilling
    ("RWF", "🇷🇼"), // Rwandan Franc
    ("ZMW", "🇿🇲"), // Zambian Kwacha
    ("MAD", "🇲🇦"), // Moroccan Dirham
    ("DZD", "🇩🇿"), // Algerian Dinar
    ("TND", "🇹🇳"), // Tunisian Dinar
    ("LYD", "🇱🇾"), // Libyan Dinar
    ("MUR", "🇲🇺"), // Mauritian Rupee
    ("ETB", "🇪🇹"), // Ethiopian Birr
    ("GEL", "🇬🇪"), // Georgian Lari
    ("GEL", "🇧🇾"), // Belarusian Ruble
    ("CRC", "🇨🇷"), // Costa Rican Colon
    ("UYU", "🇺🇾"), // Uruguayan Peso
    ("PYG", "🇵🇾"), // Paraguayan Guarani
    ("BHD", "🇧🇭"), // Bahraini Dinar
    ("OMR", "🇴🇲"), // Omani Rial
    ("JOD", "🇯🇴"), // Jordanian Dinar
    ("LBP", "🇱🇧"), // Lebanese Pound
    ("SYP", "🇸🇾"), // Syrian Pound
    ("MVR", "🇲🇻"), // Maldivian Rufiyaa
    ("MZN", "🇲🇿"), // Mozambican Metical
    ("XOF", "🇸🇳"), // West African CFA Franc
    ("XAF", "🇨🇫"), // Central African CFA Franc
    ("GIP", "🇬🇮"), // Gibraltar Pound
    ("FKP", "🇫🇰"), // Falkland Islands Pound
    ("XCD", "🇦🇮"), // East Caribbean Dollar
    ("BMD", "🇧🇲"), // Bermudian Dollar
    ("SHP", "🇸🇭"), // Saint Helena Pound
    ("AWG", "🇦🇼"), // Aruban Florin
    ("BZD", "🇧🇿"), // Belize Dollar
    ("BBD", "🇧🇧"), // Barbadian Dollar
    ("BND", "🇧🇳"), // Brunei Dollar
    ("BSD", "🇧🇸"), // Bahamian Dollar
    ("BWP", "🇧🇼"), // Botswana Pula
    ("KYD", "🇰🇾"), // Cayman Islands Dollar
    ("FJD", "🇫🇯"), // Fijian Dollar
    ("GYD", "🇬🇾"), // Guyanese Dollar
    ("JMD", "🇯🇲"), // Jamaican Dollar
    ("LAK", "🇱🇦"), // Lao Kip
    ("LRD", "🇱🇷"), // Liberian Dollar
    ("MOP", "🇲🇴"), // Macanese Pataca
]

struct AddBankAccount: View {

    @Environment(\.modelContext) private var modelContext

    @ObservedObject var states: States
    
    @State var bankInfo: BankInfo = BankInfo(amount: 0, bankName: "", currency: "", number: 0)

    var body: some View {
        NavigationStack {
            Text("Enter Bank").font(.system(size: 30, weight: .bold, design: .rounded))
                .padding(.bottom, 10)
            
            VStack(alignment: .leading) {
                
                Text("Bank Name").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)

                
                TextField("Bank Name", text: $bankInfo.bankName)
                    .textContentType(.name)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                
                Divider()
                
            }

            VStack(alignment: .leading) {
                
                Text("Bank Account").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)

                    

                TextField("Bank Account", value: $bankInfo.number, format: .number)
                
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                
                
                Divider()

            }


            VStack(alignment: .leading) {
                
                Text("Amount").font(.system(size: 20, weight: .semibold, design: .rounded)).padding(.horizontal).foregroundColor(.gray)

                
                TextField("Amount", value: $bankInfo.amount, format: .number)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                
                Divider()

            }
            
            List {
                Text("Select Currency").font(.system(size: 20, weight: .semibold, design: .rounded))

                ForEach(currenciesWithFlags, id: \.0) { name, flag in
                    HStack {
                        Text("\(name) \(flag)")
                        Spacer()
                        if(bankInfo.currency == name) {
                            Image(systemName: "hand.thumbsup.fill")
                        }
                    }                            .onTapGesture {
                        bankInfo.currency = name
                }

                }
            }.listStyle(.plain)


            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        modelContext.insert(bankInfo)
                        states.addNewAccount = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        states.addNewAccount = false
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

#Preview {
    AddBankAccount(states: States())
}
