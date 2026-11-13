//
//  NetWorthWidget.swift
//  networtWidgets
//

import WidgetKit
import SwiftUI
import Charts

struct NetWorthEntry: TimelineEntry {
    var date: Date
    /// nil until the app has run once and written a snapshot.
    var snapshot: WidgetSnapshot?
}

struct NetWorthProvider: TimelineProvider {
    func placeholder(in context: Context) -> NetWorthEntry {
        NetWorthEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (NetWorthEntry) -> Void) {
        completion(NetWorthEntry(date: .now, snapshot: context.isPreview ? (WidgetSnapshot.load() ?? .placeholder) : WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetWorthEntry>) -> Void) {
        // The app reloads timelines whenever the numbers change, so this refresh is only a fallback.
        let entry = NetWorthEntry(date: .now, snapshot: WidgetSnapshot.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(6 * 60 * 60))))
    }
}

private let positive = Color(red: 0.16, green: 0.64, blue: 0.40)
private let negative = Color(red: 0.89, green: 0.29, blue: 0.27)

private extension WidgetSnapshot {
    func amount(compact: Bool = false) -> String {
        if hidden { return "••••" }
        let style = FloatingPointFormatStyle<Double>.Currency(code: currency.uppercased())
        return compact
            ? netWorth.formatted(style.notation(.compactName).precision(.significantDigits(3)))
            : netWorth.formatted(style.precision(.fractionLength(0)))
    }

    var changeText: String? {
        guard !hidden, let monthChange else { return nil }
        let sign = monthChange >= 0 ? "+" : "−"
        let value = abs(monthChange).formatted(.currency(code: currency.uppercased()).notation(.compactName).precision(.significantDigits(3)))
        let percent = monthChangePercent.map { " (\(abs($0).formatted(.percent.precision(.fractionLength(1)))))" } ?? ""
        return sign + value + percent
    }

    var trendColor: Color {
        (monthChange ?? 0) >= 0 ? positive : negative
    }
}

// MARK: - Views

struct NetWorthWidgetView: View {
    var entry: NetWorthEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .accessoryInline:
                Text("Net worth \(snapshot.amount(compact: true))")
                    .privacySensitive()
            case .accessoryCircular:
                circular(snapshot)
            case .accessoryRectangular:
                rectangular(snapshot)
            case .systemMedium:
                medium(snapshot)
            default:
                small(snapshot)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(.tint)
                Spacer()
                Text("Net worth")
                    .font(.caption.weight(.semibold))
                Text("Open the app to get started")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func header(_ snapshot: WidgetSnapshot) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tint)
            Text("Net worth")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    func value(_ snapshot: WidgetSnapshot, size: Font) -> some View {
        Text(snapshot.amount(compact: family == .systemSmall))
            .font(size.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .privacySensitive()
            .contentTransition(.numericText(value: snapshot.netWorth))
    }

    @ViewBuilder
    func change(_ snapshot: WidgetSnapshot) -> some View {
        if let text = snapshot.changeText {
            HStack(spacing: 2) {
                Image(systemName: (snapshot.monthChange ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2.weight(.bold))
                Text(text)
                    .monospacedDigit()
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(snapshot.trendColor)
            .privacySensitive()
        } else {
            Text(snapshot.updatedAt, format: .relative(presentation: .named))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    func sparkline(_ snapshot: WidgetSnapshot) -> some View {
        if snapshot.points.count >= 2 && !snapshot.hidden {
            Chart(snapshot.points, id: \.date) { point in
                AreaMark(x: .value("Date", point.date), y: .value("Value", point.value))
                    .foregroundStyle(.linearGradient(colors: [snapshot.trendColor.opacity(0.25), snapshot.trendColor.opacity(0)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.monotone)
                LineMark(x: .value("Date", point.date), y: .value("Value", point.value))
                    .foregroundStyle(snapshot.trendColor)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    .interpolationMethod(.monotone)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: .automatic(includesZero: false))
            .privacySensitive()
        } else {
            Spacer(minLength: 0)
        }
    }

    func small(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            header(snapshot)
            Spacer(minLength: 0)
            value(snapshot, size: .title2)
            change(snapshot)
            sparkline(snapshot)
                .frame(height: 34)
                .padding(.top, 4)
        }
    }

    func medium(_ snapshot: WidgetSnapshot) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                header(snapshot)
                Spacer(minLength: 0)
                value(snapshot, size: .title)
                change(snapshot)
                if snapshot.monthChange != nil {
                    Text("Past 30 days")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            sparkline(snapshot)
                .frame(maxWidth: .infinity)
        }
    }

    func rectangular(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Net worth")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(snapshot.amount())
                .font(.headline)
                .fontDesign(.rounded)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .privacySensitive()
            if let text = snapshot.changeText {
                Text(text)
                    .font(.caption2)
                    .monospacedDigit()
                    .privacySensitive()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func circular(_ snapshot: WidgetSnapshot) -> some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: (snapshot.monthChange ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2.weight(.bold))
                Text(snapshot.amount(compact: true))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .privacySensitive()
            }
            .padding(4)
        }
    }
}

// MARK: - Widget

struct NetWorthWidget: Widget {
    let kind = "NetWorthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetWorthProvider()) { entry in
            NetWorthWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color(.systemBackground) }
        }
        .configurationDisplayName("Net Worth")
        .description("Your net worth and how it's changed this month.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}

@main
struct NetWorthWidgets: WidgetBundle {
    var body: some Widget {
        NetWorthWidget()
    }
}

#Preview(as: .systemSmall) {
    NetWorthWidget()
} timeline: {
    NetWorthEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .systemMedium) {
    NetWorthWidget()
} timeline: {
    NetWorthEntry(date: .now, snapshot: .placeholder)
}
