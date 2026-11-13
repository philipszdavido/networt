//
//  RootView.swift
//  networt
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, accounts, plan, settings
}

/// The unlocked app: four tabs, plus background work that keeps rates, prices, history and the widget current.
struct RootView: View {

    @Environment(GlobalSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @State private var tab: AppTab = .home
    @State private var loadFailed = false

    var body: some View {
        if !settings.hasRates {
            RatesLoadingView(failed: loadFailed) {
                await loadRates()
            }
            .task { await loadRates() }
        } else {
            TabView(selection: $tab) {
                Tab("Home", systemImage: "chart.pie.fill", value: .home) {
                    HomeView(selectedTab: $tab)
                }
                Tab("Accounts", systemImage: "list.bullet.rectangle.portrait.fill", value: .accounts) {
                    AccountsView()
                }
                Tab("Plan", systemImage: "target", value: .plan) {
                    PlanView()
                }
                Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                    SettingsView()
                }
            }
            .background { NetWorthObserver() }
            .task {
                await settings.refreshRatesIfStale()
                await PriceRefresher.refreshIfStale(in: modelContext, rates: settings.currencyRates)
            }
        }
    }

    func loadRates() async {
        loadFailed = false
        do {
            try await settings.refreshRates()
        } catch {
            loadFailed = true
        }
    }
}

/// Watches every holding and, when the totals change, saves today's snapshot, refreshes the widget and
/// reschedules reminders. Kept separate so these queries don't re-render the tabs.
private struct NetWorthObserver: View {
    @Environment(GlobalSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @Query private var bankInfos: [BankInfo]
    @Query private var cash: [Cash]
    @Query private var stocks: [Stock]
    @Query private var coinHoldings: [CoinHolding]
    @Query private var properties: [Property]
    @Query private var liabilities: [Liability]

    var body: some View {
        let breakdown = NetWorthCalculator(settings: settings).breakdown(
            bankInfos: bankInfos, cash: cash, stocks: stocks,
            coinHoldings: coinHoldings, properties: properties, liabilities: liabilities
        )
        let isEmpty = bankInfos.isEmpty && cash.isEmpty && stocks.isEmpty && coinHoldings.isEmpty && properties.isEmpty && liabilities.isEmpty

        Color.clear
            .task(id: breakdown) {
                guard !isEmpty else { return }
                NetWorthSnapshot.record(breakdown, currency: settings.currency, in: modelContext)
                WidgetBridge.update(in: modelContext, calculator: NetWorthCalculator(settings: settings), hidden: settings.hideNetworth)
            }
            .task(id: liabilities.map { "\($0.name)\($0.dueDate?.timeIntervalSince1970 ?? 0)" }) {
                if settings.remindersEnabled {
                    await Reminders.reschedule(liabilities: liabilities)
                }
            }
    }
}

private struct RatesLoadingView: View {
    var failed: Bool
    var retry: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            if failed {
                ContentUnavailableView {
                    Label("Can't load exchange rates", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Rates are needed once to convert your holdings. Check your connection and try again.")
                } actions: {
                    Button("Try again") { Task { await retry() } }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView()
                Text("Loading exchange rates…")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }
}

#Preview {
    RootView()
        .modelContainer(for: allModels, inMemory: true)
        .environment(GlobalSettings())
}
