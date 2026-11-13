//
//  Reminders.swift
//  networt
//

import Foundation
import UserNotifications

/// Local notifications: a heads-up before each liability's due date, plus a monthly nudge to update balances.
@MainActor
enum Reminders {
    static let liabilityPrefix = "liability-"
    static let monthlyID = "monthly-update"

    private static var center: UNUserNotificationCenter { .current() }

    static func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func reschedule(liabilities: [Liability], now: Date = .now) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(
            withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(liabilityPrefix) }
        )

        for (index, liability) in liabilities.enumerated() {
            guard let due = liability.dueDate, let fireDate = reminderDate(for: due, now: now) else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(liability.name) is due soon"
            content.body = "Due \(due.formatted(date: .abbreviated, time: .omitted))" + (liability.minPayment.map { ". Minimum payment: \($0.money(liability.currency))" } ?? "")
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let request = UNNotificationRequest(
                identifier: "\(liabilityPrefix)\(index)",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
            try? await center.add(request)
        }

        let monthly = UNMutableNotificationContent()
        monthly.title = "Time to update your balances"
        monthly.body = "A minute now keeps your net worth chart accurate."
        let request = UNNotificationRequest(
            identifier: monthlyID,
            content: monthly,
            trigger: UNCalendarNotificationTrigger(dateMatching: DateComponents(day: 1, hour: 10), repeats: true)
        )
        try? await center.add(request)
    }

    static func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    /// 9am three days before the due date, or 9am on the due date if that has already passed.
    nonisolated static func reminderDate(for due: Date, now: Date) -> Date? {
        let calendar = Calendar.current
        let dueMorning = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: due) ?? due
        let early = calendar.date(byAdding: .day, value: -3, to: dueMorning) ?? dueMorning
        return [early, dueMorning].first { $0 > now }
    }
}
