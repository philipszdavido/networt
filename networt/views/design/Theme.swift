//
//  Theme.swift
//  networt
//
//  The small design system every screen is built from: tokens, cards, rows and money text.
//

import SwiftUI

enum Theme {
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 18

    static let positive = Color(red: 0.16, green: 0.64, blue: 0.40)
    static let negative = Color(red: 0.89, green: 0.29, blue: 0.27)

    static func trend(_ value: Double) -> Color {
        value >= 0 ? positive : negative
    }
}

extension NetWorthCategory {
    var icon: String {
        switch self {
        case .bank: "building.columns.fill"
        case .cash: "banknote.fill"
        case .stocks: "chart.line.uptrend.xyaxis"
        case .crypto: "bitcoinsign"
        case .realEstate: "house.fill"
        case .liabilities: "creditcard.fill"
        }
    }

    var tint: Color {
        switch self {
        case .bank: Color(red: 0.29, green: 0.36, blue: 0.85)
        case .cash: Color(red: 0.16, green: 0.62, blue: 0.52)
        case .stocks: Color(red: 0.20, green: 0.55, blue: 0.90)
        case .crypto: Color(red: 0.95, green: 0.58, blue: 0.20)
        case .realEstate: Color(red: 0.58, green: 0.40, blue: 0.80)
        case .liabilities: Theme.negative
        }
    }

    var title: String { rawValue }
}

// MARK: - Surfaces

struct CardModifier: ViewModifier {
    var padding: CGFloat = Theme.spacing

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

extension View {
    func card(padding: CGFloat = Theme.spacing) -> some View {
        modifier(CardModifier(padding: padding))
    }

    /// Standard page background for scroll-based screens.
    func screenBackground() -> some View {
        background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct SectionHeader<Trailing: View>: View {
    var title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
            Spacer()
            trailing
                .font(.subheadline)
        }
        .padding(.horizontal, 4)
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

// MARK: - Money

/// A currency amount that respects "Hide amounts". Digits are monospaced so totals don't jitter.
struct AmountText: View {
    var amount: Double
    var currency: String
    var showsSign = false

    @Environment(GlobalSettings.self) private var settings

    var body: some View {
        Group {
            if settings.hideNetworth {
                Text("••••")
                    .accessibilityLabel("Amount hidden")
            } else {
                Text(formatted)
                    .contentTransition(.numericText(value: amount))
            }
        }
        .monospacedDigit()
    }

    var formatted: String {
        let text = abs(amount).money(currency)
        if amount < 0 { return "−" + text }
        return showsSign && amount > 0 ? "+" + text : text
    }

    init(_ amount: Double, currency: String, showsSign: Bool = false) {
        self.amount = amount
        self.currency = currency
        self.showsSign = showsSign
    }
}

/// "+$1,204 (2.4%)" in green or red.
struct ChangeLabel: View {
    var amount: Double
    var percent: Double?
    var currency: String

    @Environment(GlobalSettings.self) private var settings

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: amount >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption.weight(.bold))
            AmountText(amount, currency: currency, showsSign: true)
            if let percent, !settings.hideNetworth {
                Text("(\(abs(percent).formatted(.percent.precision(.fractionLength(1)))))")
                    .monospacedDigit()
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(Theme.trend(amount))
    }
}

// MARK: - Rows

struct IconBadge: View {
    var systemName: String
    var tint: Color
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.14), in: Circle())
            .accessibilityHidden(true)
    }
}

/// Icon, title and subtitle on the left; amount and an optional detail on the right.
struct HoldingRow<Detail: View>: View {
    var icon: String
    var tint: Color
    var title: String
    var subtitle: String?
    var amount: Double
    var currency: String
    var amountColor: Color = .primary
    @ViewBuilder var detail: Detail

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, tint: tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                AmountText(amount, currency: currency)
                    .font(.body.weight(.medium))
                    .foregroundStyle(amountColor)
                detail
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

extension HoldingRow where Detail == EmptyView {
    init(icon: String, tint: Color, title: String, subtitle: String? = nil, amount: Double, currency: String, amountColor: Color = .primary) {
        self.init(icon: icon, tint: tint, title: title, subtitle: subtitle, amount: amount, currency: currency, amountColor: amountColor) { EmptyView() }
    }
}

/// A gain or loss, shown under a holding's value.
struct GainText: View {
    var gain: Double
    var currency: String

    var body: some View {
        AmountText(gain, currency: currency, showsSign: true)
            .foregroundStyle(Theme.trend(gain))
    }
}

// MARK: - Allocation

/// A single stacked bar with a legend, the share of assets per category.
struct AllocationBar: View {
    var breakdown: NetWorthBreakdown

    var categories: [NetWorthCategory] {
        NetWorthCategory.allCases.filter { $0 != .liabilities && breakdown[$0] > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    ForEach(categories) { category in
                        Rectangle()
                            .fill(category.tint)
                            .frame(width: max(proxy.size.width * breakdown.allocation(of: category) - 2, 3))
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)

            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 8) {
                ForEach(categories) { category in
                    HStack(spacing: 6) {
                        Circle().fill(category.tint).frame(width: 8, height: 8)
                        Text(category.title)
                            .foregroundStyle(.secondary)
                        Text(breakdown.allocation(of: category).formatted(.percent.precision(.fractionLength(0))))
                            .monospacedDigit()
                    }
                    .font(.footnote)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(.white)
            .background(Color.accentColor.opacity(isEnabled ? 1 : 0.4), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

/// A compact icon-and-label action, used for "Add money" style buttons.
struct ActionButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor.opacity(0.12), in: Circle())
                Text(title)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
    }
}
