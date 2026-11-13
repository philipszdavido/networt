//
//  DebtPlannerView.swift
//  networt
//

import SwiftUI
import SwiftData

/// Compares snowball and avalanche payoff for all liabilities, in the base currency.
struct DebtPlannerView: View {

    @Environment(GlobalSettings.self) private var settings
    @Query private var liabilities: [Liability]

    @State private var strategy: DebtPlanner.Strategy = .avalanche
    @State private var extra = ""

    /// Liabilities converted to the base currency. Missing minimums default to 3% of the balance.
    static func debts(from liabilities: [Liability], calculator: NetWorthCalculator) -> [DebtPlanner.Debt] {
        liabilities.compactMap { liability in
            guard let balance = calculator.convert(abs(liability.balance), from: liability.currency), balance > 0 else { return nil }
            let minPayment = liability.minPayment.flatMap { calculator.convert($0, from: liability.currency) }
                ?? DebtPlanner.defaultMinPayment(for: balance)
            return DebtPlanner.Debt(name: liability.name, balance: balance, apr: liability.interestRate ?? 0, minPayment: minPayment)
        }
    }

    var body: some View {
        let debts = Self.debts(from: liabilities, calculator: NetWorthCalculator(settings: settings))
        let extraAmount = Double.parse(extra) ?? 0
        let plan = DebtPlanner.plan(debts, extra: extraAmount, strategy: strategy)
        let other = DebtPlanner.plan(debts, extra: extraAmount, strategy: strategy == .avalanche ? .snowball : .avalanche)
        let minimums = debts.map(\.minPayment).reduce(0, +)
        let missingDetails = liabilities.contains { $0.interestRate == nil || $0.minPayment == nil }

        Form {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    if let months = plan.months, let date = Calendar.current.date(byAdding: .month, value: months, to: .now) {
                        Text("Debt-free by")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(date.formatted(.dateTime.month(.wide).year()))
                            .font(.system(.title, design: .rounded).weight(.bold))
                        Text("\(Self.duration(months)) · \(plan.totalInterest.money(settings.currency)) interest")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Label("These payments don't cover the interest. Add an extra monthly amount.", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 6)
            }

            Section {
                Picker("Strategy", selection: $strategy) {
                    ForEach(DebtPlanner.Strategy.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                LabeledContent("Minimum payments", value: minimums.money(settings.currency))
                AmountField(title: "Extra per month", text: $extra, currency: settings.currency, prompt: "0")
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(strategy == .avalanche
                         ? "Avalanche pays the highest interest rate first and costs the least."
                         : "Snowball pays the smallest balance first for quicker wins.")
                    if let otherMonths = other.months, plan.months != nil, other.totalInterest != plan.totalInterest || otherMonths != plan.months {
                        Text("\(strategy == .avalanche ? "Snowball" : "Avalanche") would take \(Self.duration(otherMonths)) with \(other.totalInterest.money(settings.currency)) interest.")
                    }
                }
            }

            if !plan.payoffOrder.isEmpty {
                Section("Payoff order") {
                    ForEach(Array(plan.payoffOrder.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.accentColor, in: Circle())
                            Text(item.name)
                            Spacer()
                            Text(Self.duration(item.month))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }

            if missingDetails {
                Section {
                    Label("Some debts have no interest rate or minimum payment, so 0% interest and a 3% minimum are assumed. Add details for a more accurate plan.", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Debt payoff")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func duration(_ months: Int) -> String {
        let years = months / 12, rest = months % 12
        switch (years, rest) {
        case (0, _): return "\(rest) mo"
        case (_, 0): return "\(years) yr"
        default: return "\(years) yr \(rest) mo"
        }
    }
}

#Preview {
    NavigationStack {
        DebtPlannerView()
    }
    .environment(GlobalSettings())
    .modelContainer(for: allModels, inMemory: true)
}
