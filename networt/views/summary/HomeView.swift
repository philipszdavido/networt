//
//  HomeView.swift
//  networt
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @Environment(GlobalSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @Query private var bankInfos: [BankInfo]
    @Query private var cash: [Cash]
    @Query private var stocks: [Stock]
    @Query private var coinHoldings: [CoinHolding]
    @Query private var properties: [Property]
    @Query private var liabilities: [Liability]
    @Query(sort: \NetWorthSnapshot.date) private var snapshots: [NetWorthSnapshot]
    @Query(sort: \Transaction.dateTime, order: .reverse) private var transactions: [Transaction]

    @State private var range: HistoryRange = .threeMonths
    @State private var selectedPoint: HistoryPoint?
    @State private var adding: AddableType?
    @State private var showingAddMenu = false
    @State private var refreshFailures = 0

    var calculator: NetWorthCalculator { NetWorthCalculator(settings: settings) }

    var breakdown: NetWorthBreakdown {
        calculator.breakdown(bankInfos: bankInfos, cash: cash, stocks: stocks, coinHoldings: coinHoldings, properties: properties, liabilities: liabilities)
    }

    var isEmpty: Bool {
        bankInfos.isEmpty && cash.isEmpty && stocks.isEmpty && coinHoldings.isEmpty && properties.isEmpty && liabilities.isEmpty
    }

    var body: some View {
        let breakdown = breakdown
        let history = NetWorthHistory(snapshots: snapshots, calculator: calculator)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero(breakdown, history)

                    if isEmpty {
                        emptyState
                    } else {
                        if !breakdown.unconvertibleCurrencies.isEmpty {
                            warning(breakdown.unconvertibleCurrencies)
                        }

                        NetWorthHistoryChart(history: history, range: $range, selected: $selectedPoint)
                            .card()

                        HStack(spacing: 12) {
                            stat("Assets", breakdown.assets, color: .primary)
                            stat("Liabilities", breakdown.liabilities, color: breakdown.liabilities > 0 ? Theme.negative : .primary)
                        }

                        if breakdown.assets > 0 {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionHeader("Allocation")
                                AllocationBar(breakdown: breakdown)
                            }
                            .card()
                        }

                        categories(breakdown)

                        if settings.showUpdates && !transactions.isEmpty {
                            activity
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .refreshable {
                try? await settings.refreshRates()
                refreshFailures = await PriceRefresher.refreshAll(in: modelContext, rates: settings.currencyRates)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        withAnimation { settings.hideNetworth.toggle() }
                    } label: {
                        Image(systemName: settings.hideNetworth ? "eye.slash" : "eye")
                    }
                    .accessibilityLabel(settings.hideNetworth ? "Show amounts" : "Hide amounts")

                    AddMenu(adding: $adding)
                }
            }
            .sheet(item: $adding) { type in
                AddHoldingSheet(initialType: type)
            }
            .alert("Some prices couldn't be updated", isPresented: Binding(get: { refreshFailures > 0 }, set: { if !$0 { refreshFailures = 0 } })) {
                Button("OK") {}
            } message: {
                Text("\(refreshFailures) holding(s) kept their last known price.")
            }
        }
    }

    // MARK: - Sections

    func hero(_ breakdown: NetWorthBreakdown, _ history: NetWorthHistory) -> some View {
        let value = selectedPoint?.netWorth ?? breakdown.netWorth

        return VStack(alignment: .leading, spacing: 6) {
            Text(selectedPoint.map { $0.date.formatted(date: .abbreviated, time: .omitted) } ?? "Net worth")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            AmountText(value, currency: settings.currency)
                .font(.system(.largeTitle, design: settings.fontDesign == .default ? .rounded : settings.fontDesign).weight(.bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .onTapGesture { withAnimation { settings.hideNetworth.toggle() } }

            if selectedPoint == nil, let change = history.change(to: breakdown.netWorth, over: range) {
                HStack(spacing: 6) {
                    ChangeLabel(amount: change.amount, percent: change.percent, currency: settings.currency)
                    Text(range == .all ? "all time" : "past \(rangeName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let date = settings.ratesDate, selectedPoint == nil {
                Text("Rates as of \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
        .animation(.snappy, value: value)
    }

    var rangeName: String {
        switch range {
        case .month: "month"
        case .threeMonths: "3 months"
        case .year: "year"
        case .all: ""
        }
    }

    func stat(_ title: String, _ amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            AmountText(amount, currency: settings.currency)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .card()
        .accessibilityElement(children: .combine)
    }

    func categories(_ breakdown: NetWorthBreakdown) -> some View {
        let rows: [(NetWorthCategory, Int)] = [
            (.bank, bankInfos.count), (.cash, cash.count), (.stocks, stocks.count),
            (.crypto, coinHoldings.count), (.realEstate, properties.count), (.liabilities, liabilities.count),
        ].filter { $0.1 > 0 }

        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Accounts") {
                Button("See all") { selectedTab = .accounts }
            }
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.0) { index, row in
                    NavigationLink {
                        AccountsList(filter: row.0)
                    } label: {
                        HoldingRow(
                            icon: row.0.icon, tint: row.0.tint, title: row.0.title,
                            subtitle: row.1 == 1 ? "1 account" : "\(row.1) accounts",
                            amount: row.0 == .liabilities ? -breakdown[row.0] : breakdown[row.0],
                            currency: settings.currency
                        ) {
                            if row.0 != .liabilities {
                                Text(breakdown.allocation(of: row.0).formatted(.percent.precision(.fractionLength(0))))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                        .padding(.horizontal, Theme.spacing)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if index < rows.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .card(padding: 0)
        }
    }

    var activity: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Recent activity")
            VStack(spacing: 0) {
                let recent = Array(transactions.prefix(4))
                ForEach(Array(recent.enumerated()), id: \.element.id) { index, txn in
                    TransactionRow(transaction: txn, showsBank: true)
                        .padding(.horizontal, Theme.spacing)
                        .padding(.vertical, 8)
                    if index < recent.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .card(padding: 0)
        }
    }

    func warning(_ currencies: Set<String>) -> some View {
        Label {
            Text("No exchange rate for \(currencies.sorted().joined(separator: ", ")). Those holdings aren't included in your totals.")
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
        .font(.subheadline)
        .card()
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)
            VStack(spacing: 6) {
                Text("Add your first account")
                    .font(.title3.weight(.semibold))
                Text("Start with a bank account. Add cash, investments and debts whenever you're ready.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button("Add account") { adding = .bank }
                .buttonStyle(.primary)
        }
        .padding(8)
        .card(padding: 24)
        .padding(.top, 12)
    }
}

/// A "+" menu listing every kind of holding.
struct AddMenu: View {
    @Binding var adding: AddableType?

    var body: some View {
        Menu {
            ForEach(AddableType.allCases) { type in
                Button {
                    adding = type
                } label: {
                    Label(type.title, systemImage: type.category.icon)
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.body.weight(.semibold))
        }
        .accessibilityLabel("Add")
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .modelContainer(for: allModels, inMemory: true)
        .environment(GlobalSettings())
}
