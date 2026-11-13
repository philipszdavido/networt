//
//  HoldingForms.swift
//  networt
//
//  Add and edit forms for manually valued holdings. Each takes an optional record: nil adds, non-nil edits.
//

import SwiftUI
import SwiftData

// MARK: - Bank account

struct BankAccountForm: View {
    var bank: BankInfo?

    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalSettings.self) private var settings

    @State private var loaded = false
    @State private var name = ""
    @State private var number = ""
    @State private var balance = ""
    @State private var currency = ""

    var body: some View {
        Form {
            Section {
                TextField("Bank name", text: $name)
                    .textInputAutocapitalization(.words)
                TextField("Account number (optional)", text: $number)
                    .keyboardType(.numberPad)
            }
            Section {
                AmountField(title: "Balance", text: $balance, currency: currency)
                CurrencyField(selection: $currency)
            }
        }
        .navigationTitle(bank == nil ? "New bank account" : "Edit account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: !name.trimmingCharacters(in: .whitespaces).isEmpty && Double.parse(balance) != nil) {
                let target = bank ?? BankInfo(balance: 0, bankName: "", currency: currency, number: 0)
                target.bankName = name.trimmingCharacters(in: .whitespaces)
                target.number = Int(number.filter(\.isNumber).suffix(18)) ?? 0
                target.balance = Double.parse(balance) ?? 0
                target.currency = currency
                if bank == nil { modelContext.insert(target) }
            }
        }
        .onAppear {
            // Runs again when returning from the currency picker; only fill the fields once.
            guard !loaded else { return }
            loaded = true
            name = bank?.bankName ?? ""
            number = bank.map { $0.number == 0 ? "" : String($0.number) } ?? ""
            balance = bank?.balance.fieldText ?? ""
            currency = bank?.currency ?? settings.currency
        }
    }
}

/// Add money to or withdraw from a bank account, recording a transaction.
struct TransactionForm: View {
    var bank: BankInfo
    var operation: String

    @Environment(\.modelContext) private var modelContext
    @State private var amount = ""

    var body: some View {
        Form {
            Section {
                AmountField(title: "Amount", text: $amount, currency: bank.currency)
            } footer: {
                if let value = Double.parse(amount), value > 0 {
                    Text("New balance: \((bank.balance + (operation == "+" ? value : -value)).money(bank.currency))")
                }
            }
        }
        .navigationTitle(operation == "+" ? "Add money" : "Withdraw")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: (Double.parse(amount) ?? 0) > 0) {
                let value = Double.parse(amount) ?? 0
                bank.balance += operation == "+" ? value : -value
                modelContext.insert(Transaction(dateTime: .now, operation: operation, value: value, currency: bank.currency, bankInfo: bank))
            }
        }
    }
}

// MARK: - Cash

struct CashForm: View {
    var cash: Cash?

    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalSettings.self) private var settings

    @State private var loaded = false
    @State private var label = ""
    @State private var amount = ""
    @State private var currency = ""

    var body: some View {
        Form {
            Section {
                TextField("Label, e.g. Wallet", text: $label)
            }
            Section {
                AmountField(title: "Amount", text: $amount, currency: currency)
                CurrencyField(selection: $currency)
            }
        }
        .navigationTitle(cash == nil ? "New cash" : "Edit cash")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: Double.parse(amount) != nil) {
                let target = cash ?? Cash(amount: 0, currency: currency)
                target.label = label.trimmingCharacters(in: .whitespaces)
                target.amount = Double.parse(amount) ?? 0
                target.currency = currency
                if cash == nil { modelContext.insert(target) }
            }
        }
        .onAppear {
            // Runs again when returning from the currency picker; only fill the fields once.
            guard !loaded else { return }
            loaded = true
            label = cash?.label ?? ""
            amount = cash?.amount.fieldText ?? ""
            currency = cash?.currency ?? settings.currency
        }
    }
}

// MARK: - Property

struct PropertyForm: View {
    var property: Property?

    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalSettings.self) private var settings

    @State private var loaded = false
    @State private var name = ""
    @State private var currency = ""
    @State private var purchasePrice = ""
    @State private var marketValue = ""
    @State private var appreciation = ""

    var body: some View {
        Form {
            Section {
                TextField("Name or address", text: $name)
                    .textInputAutocapitalization(.words)
                CurrencyField(selection: $currency)
            }
            Section {
                AmountField(title: "Purchase price", text: $purchasePrice, currency: currency)
                AmountField(title: "Current value", text: $marketValue, currency: currency)
            }
            Section {
                AmountField(title: "Yearly growth", text: $appreciation, currency: "%", prompt: "0")
            } footer: {
                Text("Used to project the value over the next 10 years.")
            }
        }
        .navigationTitle(property == nil ? "New property" : "Edit property")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: !name.trimmingCharacters(in: .whitespaces).isEmpty && Double.parse(marketValue) != nil) {
                let value = Double.parse(marketValue) ?? 0
                let target = property ?? Property(name: "", currency: currency, purchasePrice: 0, marketValue: 0, appreciationPercent: 0)
                target.name = name.trimmingCharacters(in: .whitespaces)
                target.currency = currency
                target.marketValue = value
                target.purchasePrice = Double.parse(purchasePrice) ?? value
                target.appreciationPercent = Double.parse(appreciation) ?? 0
                if property == nil { modelContext.insert(target) }
            }
        }
        .onAppear {
            // Runs again when returning from the currency picker; only fill the fields once.
            guard !loaded else { return }
            loaded = true
            name = property?.name ?? ""
            currency = property?.currency.uppercased() ?? settings.currency
            purchasePrice = property?.purchasePrice.fieldText ?? ""
            marketValue = property?.marketValue.fieldText ?? ""
            appreciation = property?.appreciationPercent.fieldText ?? ""
        }
    }
}

struct RentalIncomeForm: View {
    var property: Property

    @State private var amount = ""
    @State private var date = Date.now
    @State private var notes = ""

    var body: some View {
        Form {
            Section {
                AmountField(title: "Amount", text: $amount, currency: property.currency)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Note (optional)", text: $notes)
            }
        }
        .navigationTitle("Rental income")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: (Double.parse(amount) ?? 0) > 0) {
                let income = RentalIncome(date: date, amount: Double.parse(amount) ?? 0, currency: property.currency, notes: notes.isEmpty ? nil : notes)
                property.rentalIncomes = (property.rentalIncomes ?? []) + [income]
            }
        }
    }
}

// MARK: - Liabilities

struct LiabilityForm: View {
    var liability: Liability?

    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalSettings.self) private var settings

    @State private var loaded = false
    @State private var name = ""
    @State private var type = LiabilityType.loan
    @State private var currency = ""
    @State private var balance = ""
    @State private var creditLimit = ""
    @State private var interestRate = ""
    @State private var minPayment = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date.now

    var body: some View {
        Form {
            Section {
                Picker("Type", selection: $type) {
                    ForEach(LiabilityType.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Section {
                TextField(type == .creditCard ? "Card name" : "Loan name", text: $name)
                    .textInputAutocapitalization(.words)
                AmountField(title: "Amount owed", text: $balance, currency: currency)
                CurrencyField(selection: $currency)
                if type == .creditCard {
                    AmountField(title: "Credit limit", text: $creditLimit, currency: currency, prompt: "Optional")
                }
            }
            Section {
                AmountField(title: "Interest rate (APR)", text: $interestRate, currency: "%", prompt: "Optional")
                AmountField(title: "Minimum payment", text: $minPayment, currency: currency, prompt: "Optional")
                Toggle("Due date", isOn: $hasDueDate.animation())
                if hasDueDate {
                    DatePicker("Next due", selection: $dueDate, displayedComponents: .date)
                }
            } footer: {
                Text("Interest and minimum payment power the debt payoff plan. A due date lets us remind you.")
            }
        }
        .navigationTitle(liability == nil ? "New debt" : "Edit debt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: !name.trimmingCharacters(in: .whitespaces).isEmpty && Double.parse(balance) != nil) {
                let target = liability ?? Liability(name: "", type: type, currency: currency, balance: 0)
                target.name = name.trimmingCharacters(in: .whitespaces)
                target.type = type
                target.currency = currency
                target.balance = Double.parse(balance) ?? 0
                target.creditLimit = type == .creditCard ? Double.parse(creditLimit) : nil
                target.interestRate = Double.parse(interestRate)
                target.minPayment = Double.parse(minPayment)
                target.dueDate = hasDueDate ? dueDate : nil
                if liability == nil { modelContext.insert(target) }
            }
        }
        .onAppear {
            // Runs again when returning from the currency picker; only fill the fields once.
            guard !loaded else { return }
            loaded = true
            guard let liability else {
                currency = settings.currency
                return
            }
            name = liability.name
            type = liability.type
            currency = liability.currency.uppercased()
            balance = liability.balance.fieldText
            creditLimit = liability.creditLimit.fieldText
            interestRate = liability.interestRate.fieldText
            minPayment = liability.minPayment.fieldText
            hasDueDate = liability.dueDate != nil
            dueDate = liability.dueDate ?? .now
        }
    }
}

/// Records a payment and reduces the balance, converting when the payment currency differs.
struct PaymentForm: View {
    var liability: Liability

    @Environment(GlobalSettings.self) private var settings

    @State private var loaded = false
    @State private var amount = ""
    @State private var currency = ""
    @State private var date = Date.now
    @State private var note = ""

    var reduction: Double? {
        guard let value = Double.parse(amount), value > 0 else { return nil }
        return NetWorthCalculator(baseCurrency: liability.currency, rates: settings.currencyRates).convert(value, from: currency)
    }

    var body: some View {
        Form {
            Section {
                AmountField(title: "Amount", text: $amount, currency: currency)
                CurrencyField(selection: $currency)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Note (optional)", text: $note)
            } footer: {
                if let reduction {
                    Text("Remaining balance: \(max(liability.balance - reduction, 0).money(liability.currency))")
                } else if Double.parse(amount) != nil, currency.lowercased() != liability.currency.lowercased() {
                    Text("No exchange rate from \(currency.uppercased()) to \(liability.currency.uppercased()).")
                        .foregroundStyle(Theme.negative)
                }
            }
            if let minPayment = liability.minPayment, amount.isEmpty {
                Section {
                    Button("Pay minimum (\(minPayment.money(liability.currency)))") {
                        currency = liability.currency.uppercased()
                        amount = minPayment.fieldText
                    }
                }
            }
        }
        .navigationTitle("Record payment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: reduction != nil) {
                guard let reduction else { return }
                let payment = Payment(currency: currency, amount: Double.parse(amount) ?? 0, date: date, note: note.isEmpty ? nil : note)
                liability.payments = (liability.payments ?? []) + [payment]
                liability.balance -= reduction
            }
        }
        .onAppear {
            // Runs again when returning from the currency picker; only fill the fields once.
            guard !loaded else { return }
            loaded = true
            currency = liability.currency.uppercased()
        }
    }
}

#Preview {
    NavigationStack {
        LiabilityForm()
    }
    .modelContainer(for: allModels, inMemory: true)
    .environment(GlobalSettings())
}
