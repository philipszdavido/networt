//
//  PlanView.swift
//  networt
//

import SwiftUI
import SwiftData

/// Goals and debt payoff.
struct PlanView: View {

    @Environment(GlobalSettings.self) private var settings

    @Query private var bankInfos: [BankInfo]
    @Query private var cash: [Cash]
    @Query private var stocks: [Stock]
    @Query private var coinHoldings: [CoinHolding]
    @Query private var properties: [Property]
    @Query private var liabilities: [Liability]

    @State private var editingGoals = false

    var body: some View {
        let calculator = NetWorthCalculator(settings: settings)
        let breakdown = calculator.breakdown(bankInfos: bankInfos, cash: cash, stocks: stocks, coinHoldings: coinHoldings, properties: properties, liabilities: liabilities)
        let debts = DebtPlannerView.debts(from: liabilities, calculator: calculator)
        let plan = DebtPlanner.plan(debts, extra: 0, strategy: .avalanche)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Goals") {
                            Button(settings.netWorthGoal > 0 || settings.emergencyFundGoal > 0 ? "Edit" : "Set goals") { editingGoals = true }
                        }
                        if settings.netWorthGoal <= 0 && settings.emergencyFundGoal <= 0 {
                            emptyGoals
                        } else {
                            if settings.netWorthGoal > 0 {
                                GoalCard(title: "Net worth", icon: "flag.checkered", tint: .accentColor,
                                         current: breakdown.netWorth, target: settings.netWorthGoal)
                            }
                            if settings.emergencyFundGoal > 0 {
                                GoalCard(title: "Emergency fund", icon: "lifepreserver", tint: NetWorthCategory.cash.tint,
                                         current: breakdown[.bank] + breakdown[.cash], target: settings.emergencyFundGoal)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader("Debt")
                        if debts.isEmpty {
                            Label("You have no debts recorded.", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Theme.positive)
                                .card()
                        } else {
                            NavigationLink {
                                DebtPlannerView()
                            } label: {
                                debtCard(total: breakdown.liabilities, plan: plan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .screenBackground()
            .navigationTitle("Plan")
            .sheet(isPresented: $editingGoals) {
                NavigationStack { GoalsForm() }
                    .presentationDetents([.medium])
            }
        }
    }

    var emptyGoals: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Give your money a direction")
                .font(.body.weight(.semibold))
            Text("Set a net worth target or an emergency fund and track your progress here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    func debtCard(total: Double, plan: DebtPlanner.Plan) -> some View {
        HStack(alignment: .center, spacing: 14) {
            IconBadge(systemName: "calendar.badge.checkmark", tint: Theme.positive, size: 44)
            VStack(alignment: .leading, spacing: 4) {
                if let months = plan.months, let date = Calendar.current.date(byAdding: .month, value: months, to: .now) {
                    Text("Debt-free by \(date.formatted(.dateTime.month(.wide).year()))")
                        .font(.body.weight(.semibold))
                } else {
                    Text("Minimums don't cover the interest")
                        .font(.body.weight(.semibold))
                }
                HStack(spacing: 4) {
                    AmountText(total, currency: settings.currency)
                    Text("owed · paying minimums")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .card()
        .contentShape(Rectangle())
    }
}

struct GoalCard: View {
    var title: String
    var icon: String
    var tint: Color
    var current: Double
    var target: Double

    @Environment(GlobalSettings.self) private var settings

    var progress: Double { min(max(current / target, 0), 1) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(tint.opacity(0.15), lineWidth: 6)
                Circle().trim(from: 0, to: progress)
                    .stroke(progress >= 1 ? Theme.positive : tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: progress >= 1 ? "checkmark" : icon)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(progress >= 1 ? Theme.positive : tint)
            }
            .frame(width: 52, height: 52)
            .animation(.snappy, value: progress)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.body.weight(.semibold))
                    Spacer()
                    Text(progress.formatted(.percent.precision(.fractionLength(0))))
                        .font(.body.weight(.semibold))
                        .monospacedDigit()
                }
                HStack(spacing: 4) {
                    AmountText(current, currency: settings.currency)
                    Text("of")
                    AmountText(target, currency: settings.currency)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                if progress < 1 && !settings.hideNetworth {
                    Text("\((target - current).money(settings.currency)) to go")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .card()
        .accessibilityElement(children: .combine)
    }
}

struct GoalsForm: View {
    @Environment(GlobalSettings.self) private var settings

    @State private var netWorth = ""
    @State private var emergencyFund = ""

    var body: some View {
        Form {
            Section {
                AmountField(title: "Net worth goal", text: $netWorth, currency: settings.currency, prompt: "None")
            }
            Section {
                AmountField(title: "Emergency fund", text: $emergencyFund, currency: settings.currency, prompt: "None")
            } footer: {
                Text("Measured against your bank and cash balances. Three to six months of expenses is a common target.")
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            FormToolbar(canSave: true) {
                settings.netWorthGoal = Double.parse(netWorth) ?? 0
                settings.emergencyFundGoal = Double.parse(emergencyFund) ?? 0
            }
        }
        .onAppear {
            netWorth = settings.netWorthGoal > 0 ? settings.netWorthGoal.fieldText : ""
            emergencyFund = settings.emergencyFundGoal > 0 ? settings.emergencyFundGoal.fieldText : ""
        }
    }
}

#Preview {
    PlanView()
        .modelContainer(for: allModels, inMemory: true)
        .environment(GlobalSettings())
}
