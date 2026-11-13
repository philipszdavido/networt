//
//  DebtPlanner.swift
//  networt
//

import Foundation

/// Month-by-month payoff simulation for the snowball and avalanche strategies.
enum DebtPlanner {

    struct Debt: Equatable {
        var name: String
        var balance: Double
        /// Annual rate in percent, e.g. 19.9.
        var apr: Double
        var minPayment: Double
    }

    enum Strategy: String, CaseIterable, Identifiable {
        /// Smallest balance first.
        case snowball = "Snowball"
        /// Highest interest rate first.
        case avalanche = "Avalanche"

        var id: String { rawValue }
    }

    struct Plan: Equatable {
        /// nil when the payments never cover the interest.
        var months: Int?
        var totalInterest: Double
        /// Debt names with the month (1-based) each one is paid off.
        var payoffOrder: [(name: String, month: Int)]

        static func == (lhs: Plan, rhs: Plan) -> Bool {
            lhs.months == rhs.months && lhs.totalInterest == rhs.totalInterest
                && lhs.payoffOrder.map(\.name) == rhs.payoffOrder.map(\.name)
                && lhs.payoffOrder.map(\.month) == rhs.payoffOrder.map(\.month)
        }
    }

    static let maxMonths = 600

    /// The monthly budget is every debt's minimum plus `extra`; a paid-off debt's minimum rolls into the next target.
    static func plan(_ debts: [Debt], extra: Double, strategy: Strategy) -> Plan {
        var debts = debts.filter { $0.balance > 0.005 }
        let budget = debts.map(\.minPayment).reduce(0, +) + max(extra, 0)
        var totalInterest = 0.0
        var payoffOrder: [(name: String, month: Int)] = []
        var month = 0

        while !debts.isEmpty {
            month += 1
            if month > maxMonths {
                return Plan(months: nil, totalInterest: totalInterest, payoffOrder: payoffOrder)
            }

            for index in debts.indices {
                let interest = debts[index].balance * debts[index].apr / 1200
                debts[index].balance += interest
                totalInterest += interest
            }

            var remaining = budget
            for index in debts.indices {
                let payment = min(debts[index].minPayment, debts[index].balance, remaining)
                debts[index].balance -= payment
                remaining -= payment
            }

            for index in priority(debts, strategy) where remaining > 0 {
                let payment = min(debts[index].balance, remaining)
                debts[index].balance -= payment
                remaining -= payment
            }

            for debt in debts where debt.balance <= 0.005 {
                payoffOrder.append((debt.name, month))
            }
            debts.removeAll { $0.balance <= 0.005 }
        }

        return Plan(months: month, totalInterest: totalInterest, payoffOrder: payoffOrder)
    }

    private static func priority(_ debts: [Debt], _ strategy: Strategy) -> [Int] {
        debts.indices.sorted { a, b in
            switch strategy {
            case .snowball: debts[a].balance < debts[b].balance
            case .avalanche: debts[a].apr > debts[b].apr
            }
        }
    }

    /// Minimum payment to assume when none was entered: 3% of the balance.
    static func defaultMinPayment(for balance: Double) -> Double {
        balance * 0.03
    }
}
