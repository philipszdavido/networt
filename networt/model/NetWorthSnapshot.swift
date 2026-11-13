//
//  NetWorthSnapshot.swift
//  networt
//

import Foundation
import SwiftData

/// One row per day, recording net worth in the base currency that was active at the time.
@Model
class NetWorthSnapshot {
    var date: Date = Date.now
    var currency: String = "USD"
    var assets: Double = 0
    var liabilities: Double = 0
    var netWorth: Double = 0

    init(date: Date, currency: String, assets: Double, liabilities: Double, netWorth: Double) {
        self.date = date
        self.currency = currency
        self.assets = assets
        self.liabilities = liabilities
        self.netWorth = netWorth
    }

    /// Inserts or updates today's snapshot.
    static func record(_ breakdown: NetWorthBreakdown, currency: String, in context: ModelContext, now: Date = .now) {
        let day = Calendar.current.startOfDay(for: now)
        let descriptor = FetchDescriptor<NetWorthSnapshot>(predicate: #Predicate { $0.date == day })

        let todays = (try? context.fetch(descriptor)) ?? []
        // With iCloud sync, two devices can each have written today's row; keep one.
        todays.dropFirst().forEach(context.delete)

        if let existing = todays.first {
            existing.currency = currency
            existing.assets = breakdown.assets
            existing.liabilities = breakdown.liabilities
            existing.netWorth = breakdown.netWorth
        } else {
            context.insert(
                NetWorthSnapshot(
                    date: day,
                    currency: currency,
                    assets: breakdown.assets,
                    liabilities: breakdown.liabilities,
                    netWorth: breakdown.netWorth
                )
            )
        }
    }
}
