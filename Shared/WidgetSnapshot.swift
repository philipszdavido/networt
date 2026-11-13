//
//  WidgetSnapshot.swift
//  Shared between the app and the widget extension.
//

import Foundation

/// What the widgets show. The app writes it to the App Group container; the widget only reads it.
struct WidgetSnapshot: Codable, Equatable {
    struct Point: Codable, Equatable {
        var date: Date
        var value: Double
    }

    var netWorth: Double
    var currency: String
    /// Change over the last 30 days, when there is history that old.
    var monthChange: Double?
    var monthChangePercent: Double?
    /// Up to 90 days of daily net worth, oldest first.
    var points: [Point]
    var hidden: Bool
    var updatedAt: Date

    static let appGroup = "group.chidumennamdi.networth"

    static var fileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("widget-snapshot.json")
    }

    static func load(from url: URL? = fileURL) -> WidgetSnapshot? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(WidgetSnapshot.self, from: data)
    }

    @discardableResult
    func save(to url: URL? = fileURL) -> Bool {
        guard let url else { return false }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self) else { return false }
        return (try? data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])) != nil
    }

    static let placeholder = WidgetSnapshot(
        netWorth: 128_450,
        currency: "USD",
        monthChange: 3_210,
        monthChangePercent: 0.0256,
        points: (0..<30).map { day in
            Point(date: Calendar.current.date(byAdding: .day, value: day - 29, to: .now)!,
                  value: 120_000 + Double(day) * 280 + sin(Double(day) / 3) * 900)
        },
        hidden: false,
        updatedAt: .now
    )
}
