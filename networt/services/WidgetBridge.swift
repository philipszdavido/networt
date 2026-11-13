//
//  WidgetBridge.swift
//  networt
//

import Foundation
import SwiftData
import WidgetKit

/// Writes the widget's snapshot and asks WidgetKit to redraw.
@MainActor
enum WidgetBridge {

    static func update(in context: ModelContext, calculator: NetWorthCalculator, hidden: Bool) {
        func fetch<T: PersistentModel>(_: T.Type) -> [T] { (try? context.fetch(FetchDescriptor<T>())) ?? [] }
        let breakdown = calculator.breakdown(
            bankInfos: fetch(BankInfo.self), cash: fetch(Cash.self), stocks: fetch(Stock.self),
            coinHoldings: fetch(CoinHolding.self), properties: fetch(Property.self), liabilities: fetch(Liability.self)
        )
        let history = NetWorthHistory(snapshots: fetch(NetWorthSnapshot.self), calculator: calculator)

        write(make(netWorth: breakdown.netWorth, currency: calculator.baseCurrency, history: history.points, hidden: hidden))
    }

    /// Builds the snapshot; split out so it can be tested without WidgetKit.
    nonisolated static func make(netWorth: Double, currency: String, history: [HistoryPoint], hidden: Bool, now: Date = .now) -> WidgetSnapshot {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: now) ?? now
        var points = history.filter { $0.date >= cutoff && !Calendar.current.isDate($0.date, inSameDayAs: now) }
            .map { WidgetSnapshot.Point(date: $0.date, value: $0.netWorth) }
        points.append(.init(date: now, value: netWorth))

        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        let base = history.last { $0.date <= monthAgo }
        let change = base.map { netWorth - $0.netWorth }

        return WidgetSnapshot(
            netWorth: netWorth,
            currency: currency,
            monthChange: change,
            monthChangePercent: base.flatMap { $0.netWorth != 0 ? (netWorth - $0.netWorth) / abs($0.netWorth) : nil },
            points: points,
            hidden: hidden,
            updatedAt: now
        )
    }

    nonisolated static func setHidden(_ hidden: Bool) {
        guard var snapshot = WidgetSnapshot.load(), snapshot.hidden != hidden else { return }
        snapshot.hidden = hidden
        if snapshot.save() {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private static func write(_ snapshot: WidgetSnapshot) {
        // Skip the write (and the widget reload) when only the timestamp would change.
        if var current = WidgetSnapshot.load() {
            current.updatedAt = snapshot.updatedAt
            if current == snapshot { return }
        }
        if snapshot.save() {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
