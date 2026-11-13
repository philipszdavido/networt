//
//  FormComponents.swift
//  networt
//

import SwiftUI

/// The kinds of things a user can add.
enum AddableType: String, CaseIterable, Identifiable {
    case bank, cash, stock, crypto, property, liability

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bank: "Bank account"
        case .cash: "Cash"
        case .stock: "Stock or ETF"
        case .crypto: "Crypto"
        case .property: "Property"
        case .liability: "Loan or credit card"
        }
    }

    var category: NetWorthCategory {
        switch self {
        case .bank: .bank
        case .cash: .cash
        case .stock: .stocks
        case .crypto: .crypto
        case .property: .realEstate
        case .liability: .liabilities
        }
    }
}

/// Sheet wrapper for the add forms.
struct AddHoldingSheet: View {
    var initialType: AddableType

    var body: some View {
        NavigationStack {
            switch initialType {
            case .bank: BankAccountForm()
            case .cash: CashForm()
            case .stock: StockForm()
            case .crypto: CryptoForm()
            case .property: PropertyForm()
            case .liability: LiabilityForm()
            }
        }
    }
}

/// A right-aligned decimal field with the currency code after it.
struct AmountField: View {
    var title: String
    @Binding var text: String
    var currency: String? = nil
    var prompt: String = "0.00"

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 6) {
                TextField(prompt, text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                if let currency {
                    Text(currency.uppercased())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Cancel and Save toolbar shared by every form.
struct FormToolbar: ToolbarContent {
    var canSave: Bool
    var save: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                save()
                dismiss()
            }
            .fontWeight(.semibold)
            .disabled(!canSave)
        }
    }
}

extension Double {
    /// A plain number for pre-filling an edit field ("1250.5", no grouping).
    var fieldText: String {
        formatted(.number.grouping(.never).precision(.fractionLength(0...8)))
    }
}

extension Optional where Wrapped == Double {
    var fieldText: String {
        map(\.fieldText) ?? ""
    }
}
