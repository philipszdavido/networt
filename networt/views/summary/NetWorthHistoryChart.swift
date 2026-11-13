//
//  NetWorthHistoryChart.swift
//  networt
//

import SwiftUI
import Charts

enum HistoryRange: String, CaseIterable, Identifiable {
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"
    case all = "All"

    var id: String { rawValue }

    var start: Date? {
        let calendar = Calendar.current
        switch self {
        case .month: return calendar.date(byAdding: .month, value: -1, to: .now)
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: .now)
        case .year: return calendar.date(byAdding: .year, value: -1, to: .now)
        case .all: return nil
        }
    }
}

struct HistoryPoint: Identifiable, Equatable {
    var date: Date
    var assets: Double
    var liabilities: Double

    var netWorth: Double { assets - liabilities }
    var id: Date { date }
}

/// Snapshots converted into the current base currency, one point per day.
struct NetWorthHistory {
    var points: [HistoryPoint]

    init(snapshots: [NetWorthSnapshot], calculator: NetWorthCalculator) {
        var byDay: [Date: HistoryPoint] = [:]
        for snapshot in snapshots {
            guard
                let assets = calculator.convert(snapshot.assets, from: snapshot.currency),
                let liabilities = calculator.convert(snapshot.liabilities, from: snapshot.currency)
            else { continue }
            // Synced devices can each write a row for the same day; the last one wins.
            byDay[Calendar.current.startOfDay(for: snapshot.date)] = HistoryPoint(date: snapshot.date, assets: assets, liabilities: liabilities)
        }
        points = byDay.values.sorted { $0.date < $1.date }
    }

    func points(in range: HistoryRange) -> [HistoryPoint] {
        guard let start = range.start else { return points }
        return points.filter { $0.date >= start }
    }

    /// Change from the first point in `range` (or the closest one) to `current`.
    func change(to current: Double, over range: HistoryRange) -> (amount: Double, percent: Double?)? {
        guard let first = points(in: range).first ?? points.last, first.date < Calendar.current.startOfDay(for: .now) else { return nil }
        let amount = current - first.netWorth
        return (amount, first.netWorth != 0 ? amount / abs(first.netWorth) : nil)
    }
}

/// A clean line chart with a range selector underneath and a drag-to-inspect readout.
struct NetWorthHistoryChart: View {
    var history: NetWorthHistory
    @Binding var range: HistoryRange
    @Binding var selected: HistoryPoint?

    @Environment(GlobalSettings.self) private var settings

    var points: [HistoryPoint] { history.points(in: range) }

    var trendColor: Color {
        guard let first = points.first, let last = points.last else { return .accentColor }
        return Theme.trend(last.netWorth - first.netWorth)
    }

    var body: some View {
        VStack(spacing: 16) {
            if points.count < 2 {
                VStack(spacing: 6) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("Your chart starts tomorrow")
                        .font(.subheadline.weight(.medium))
                    Text("We save your net worth once a day.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                Chart(points) { point in
                    AreaMark(x: .value("Date", point.date), y: .value("Net worth", point.netWorth))
                        .foregroundStyle(.linearGradient(colors: [trendColor.opacity(0.22), trendColor.opacity(0)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.monotone)
                    LineMark(x: .value("Date", point.date), y: .value("Net worth", point.netWorth))
                        .foregroundStyle(trendColor)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .interpolationMethod(.monotone)

                    if let selected, selected.id == point.id {
                        RuleMark(x: .value("Date", selected.date))
                            .foregroundStyle(Color.secondary.opacity(0.4))
                        PointMark(x: .value("Date", selected.date), y: .value("Net worth", selected.netWorth))
                            .foregroundStyle(trendColor)
                            .symbolSize(70)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard let plot = proxy.plotFrame else { return }
                                        let x = value.location.x - geometry[plot].origin.x
                                        if let date: Date = proxy.value(atX: x) {
                                            selected = points.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
                                        }
                                    }
                                    .onEnded { _ in selected = nil }
                            )
                    }
                }
                .frame(height: 180)
                .redacted(reason: settings.hideNetworth ? .placeholder : [])
                .accessibilityLabel("Net worth chart")
                .accessibilityValue(points.last.map { "Latest \($0.netWorth.money(settings.currency))" } ?? "")
            }

            HStack(spacing: 4) {
                ForEach(HistoryRange.allCases) { option in
                    Button {
                        withAnimation(.snappy) { range = option }
                    } label: {
                        Text(option.rawValue)
                            .font(.footnote.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .foregroundStyle(range == option ? Color.primary : Color.secondary)
                            .background(range == option ? Color(.tertiarySystemFill) : .clear, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(range == option ? .isSelected : [])
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selected?.id)
    }
}
