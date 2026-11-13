//
//  CurrencyPicker.swift
//  networt
//

import SwiftUI

/// Searchable list of every currency with a rate. Tapping one selects it and goes back.
struct CurrencyPicker: View {
    @Binding var selection: String

    @Environment(GlobalSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    static let popular = ["usd", "eur", "gbp", "ngn", "cad", "jpy", "inr", "aud"]

    var results: [String] {
        let all = settings.availableCurrencies
        guard !search.isEmpty else { return all }
        return all.filter { $0.localizedStandardContains(search) || settings.currencyName($0).localizedStandardContains(search) }
    }

    var body: some View {
        List {
            if search.isEmpty {
                Section("Popular") {
                    ForEach(Self.popular.filter { settings.currencyRates.data[$0] != nil }, id: \.self, content: row)
                }
            }
            Section(search.isEmpty ? "All currencies" : "Results") {
                ForEach(results, id: \.self, content: row)
            }
        }
        .overlay {
            if settings.availableCurrencies.isEmpty {
                ContentUnavailableView("No currencies yet", systemImage: "globe", description: Text("Currencies appear once exchange rates have loaded."))
            } else if results.isEmpty {
                ContentUnavailableView.search(text: search)
            }
        }
        .searchable(text: $search, prompt: "Code or name")
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }

    func row(_ code: String) -> some View {
        Button {
            selection = code.uppercased()
            dismiss()
        } label: {
            HStack {
                Text(code.uppercased())
                    .font(.body.weight(.semibold))
                    .frame(width: 56, alignment: .leading)
                Text(settings.currencyName(code))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                if selection.lowercased() == code {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

/// A form row that opens `CurrencyPicker`.
struct CurrencyField: View {
    var title = "Currency"
    @Binding var selection: String

    @Environment(GlobalSettings.self) private var settings

    var body: some View {
        NavigationLink {
            CurrencyPicker(selection: $selection)
        } label: {
            LabeledContent(title) {
                Text(selection.uppercased())
            }
        }
    }
}

#Preview {
    NavigationStack {
        CurrencyPicker(selection: .constant("USD"))
    }
    .environment(GlobalSettings())
}
