//
//  DetailViews.swift
//  networt
//
//  One detail screen per kind of holding, built from the same header and stat grid.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Shared pieces

/// Icon, name and the big value at the top of every detail screen.
struct DetailHeader<Detail: View>: View {
    var icon: String
    var tint: Color
    var title: String
    var subtitle: String?
    var amount: Double
    var currency: String
    @ViewBuilder var detail: Detail

    var body: some View {
        VStack(spacing: 10) {
            IconBadge(systemName: icon, tint: tint, size: 52)
            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            AmountText(amount, currency: currency)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            detail
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

/// A two-column grid of label/value pairs inside a card.
struct StatGrid: View {
    var items: [(String, String)]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
            ForEach(Array(stride(from: 0, to: items.count, by: 2)), id: \.self) { index in
                GridRow {
                    cell(items[index])
                    if index + 1 < items.count { cell(items[index + 1]) } else { Color.clear }
                }
            }
        }
        .card()
    }

    func cell(_ item: (String, String)) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.0)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(item.1)
                .font(.body.weight(.medium))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Edit and delete in the toolbar; delete asks first, then pops the screen.
struct DetailToolbar: ToolbarContent {
    var name: String
    var edit: () -> Void
    var delete: () -> Void

    @State private var confirming = false
    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Edit", systemImage: "pencil", action: edit)
                Button("Delete", systemImage: "trash", role: .destructive) { confirming = true }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .confirmationDialog("Delete \(name)?", isPresented: $confirming, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    dismiss()
                    delete()
                }
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    var showsBank = false

    var body: some View {
        let isDeposit = transaction.operation == "+"
        HoldingRow(
            icon: isDeposit ? "arrow.down.left" : "arrow.up.right",
            tint: isDeposit ? Theme.positive : .secondary,
            title: showsBank ? (transaction.bankInfo?.bankName ?? (isDeposit ? "Deposit" : "Withdrawal")) : (isDeposit ? "Deposit" : "Withdrawal"),
            subtitle: transaction.dateTime.formatted(.relative(presentation: .named)),
            amount: isDeposit ? transaction.value : -transaction.value,
            currency: transaction.currency,
            amountColor: isDeposit ? Theme.positive : .primary
        )
    }
}

private func statDate(_ date: Date?) -> String {
    date?.formatted(.relative(presentation: .named)) ?? "—"
}

// MARK: - Bank

struct BankAccountDetailView: View {
    @Bindable var bank: BankInfo

    @Environment(\.modelContext) private var modelContext
    @State private var operation: String?
    @State private var editing = false

    var transactions: [Transaction] {
        (bank.transactions ?? []).sorted { $0.dateTime > $1.dateTime }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DetailHeader(icon: NetWorthCategory.bank.icon, tint: NetWorthCategory.bank.tint, title: bank.bankName,
                             subtitle: bank.number == 0 ? nil : "Account •• \(String(bank.number).suffix(4))",
                             amount: bank.balance, currency: bank.currency) { EmptyView() }

                HStack(spacing: 32) {
                    ActionButton(title: "Add money", systemImage: "plus") { operation = "+" }
                    ActionButton(title: "Withdraw", systemImage: "minus") { operation = "-" }
                    ActionButton(title: "Edit", systemImage: "pencil") { editing = true }
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Activity")
                    if transactions.isEmpty {
                        Text("Deposits and withdrawals you record appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .card()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(transactions.enumerated()), id: \.element.id) { index, txn in
                                TransactionRow(transaction: txn)
                                    .padding(.horizontal, Theme.spacing)
                                    .padding(.vertical, 8)
                                if index < transactions.count - 1 { Divider().padding(.leading, 64) }
                            }
                        }
                        .card(padding: 0)
                    }
                }
            }
            .padding()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DetailToolbar(name: bank.bankName, edit: { editing = true }, delete: { modelContext.delete(bank) })
        }
        .sheet(item: Binding(get: { operation.map(IdentifiedString.init) }, set: { operation = $0?.value })) { op in
            NavigationStack { TransactionForm(bank: bank, operation: op.value) }
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $editing) {
            NavigationStack { BankAccountForm(bank: bank) }
        }
    }
}

private struct IdentifiedString: Identifiable {
    var value: String
    var id: String { value }
}

// MARK: - Stock

struct StockDetailView: View {
    @Bindable var stock: Stock

    @Environment(\.modelContext) private var modelContext
    @State private var editing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DetailHeader(icon: NetWorthCategory.stocks.icon, tint: NetWorthCategory.stocks.tint, title: stock.symbol,
                             subtitle: stock.name == stock.symbol ? stock.exchange : stock.name,
                             amount: stock.marketValue, currency: stock.currency) {
                    if let gain = stock.unrealizedGain, let cost = stock.costBasis, cost > 0 {
                        ChangeLabel(amount: gain, percent: gain / (cost * Double(stock.quantity)), currency: stock.currency)
                    }
                }

                StatGrid(items: [
                    ("Shares", "\(stock.quantity)"),
                    ("Price", stock.price.money(stock.currency)),
                    ("Average cost", stock.costBasis?.money(stock.currency) ?? "—"),
                    ("Price updated", statDate(stock.priceUpdatedAt)),
                ])
            }
            .padding()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DetailToolbar(name: stock.symbol, edit: { editing = true }, delete: { modelContext.delete(stock) })
        }
        .sheet(isPresented: $editing) {
            NavigationStack { StockForm(stock: stock) }
        }
    }
}

// MARK: - Crypto

struct CryptoDetailView: View {
    @Bindable var holding: CoinHolding

    @Environment(\.modelContext) private var modelContext
    @State private var editing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DetailHeader(icon: NetWorthCategory.crypto.icon, tint: NetWorthCategory.crypto.tint, title: holding.name,
                             subtitle: holding.symbol, amount: holding.totalValue, currency: "USD") {
                    if let gain = holding.unrealizedGain, let cost = holding.costBasis, cost > 0 {
                        ChangeLabel(amount: gain, percent: gain / (cost * holding.amount), currency: "USD")
                    }
                }

                StatGrid(items: [
                    ("Amount", "\(holding.amount.formatted(.number.precision(.fractionLength(0...8)))) \(holding.symbol)"),
                    ("Price", holding.price.money("USD")),
                    ("Average cost", holding.costBasis?.money("USD") ?? "—"),
                    ("Price updated", statDate(holding.coin?.priceUpdatedAt)),
                ])
            }
            .padding()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DetailToolbar(name: holding.name, edit: { editing = true }, delete: { modelContext.delete(holding) })
        }
        .sheet(isPresented: $editing) {
            NavigationStack { CryptoForm(holding: holding) }
        }
    }
}

// MARK: - Property

struct PropertyDetailView: View {
    @Bindable var property: Property

    @Environment(\.modelContext) private var modelContext
    @Environment(GlobalSettings.self) private var settings
    @State private var editing = false
    @State private var addingIncome = false

    var projection: [(year: Int, value: Double)] {
        (0...10).map { ($0, property.projectedValue(afterYears: $0)) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DetailHeader(icon: NetWorthCategory.realEstate.icon, tint: NetWorthCategory.realEstate.tint, title: property.name,
                             subtitle: nil, amount: property.marketValue, currency: property.currency) {
                    ChangeLabel(amount: property.gain, percent: property.purchasePrice > 0 ? property.gain / property.purchasePrice : nil, currency: property.currency)
                }

                StatGrid(items: [
                    ("Purchase price", property.purchasePrice.money(property.currency)),
                    ("Return", "\(property.roi.formatted(.number.precision(.fractionLength(1))))%"),
                    ("Yearly growth", "\(property.appreciationPercent.formatted(.number.precision(.fractionLength(0...2))))%"),
                    ("Rental income", property.totalRentalIncome.money(property.currency)),
                ])

                if property.appreciationPercent != 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "10-year projection") {
                            AmountText(property.projectedValue(afterYears: 10), currency: property.currency)
                                .foregroundStyle(.secondary)
                        }
                        Chart(projection, id: \.year) { point in
                            AreaMark(x: .value("Year", point.year), y: .value("Value", point.value))
                                .foregroundStyle(.linearGradient(colors: [NetWorthCategory.realEstate.tint.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
                            LineMark(x: .value("Year", point.year), y: .value("Value", point.value))
                                .foregroundStyle(NetWorthCategory.realEstate.tint)
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks(values: [0, 5, 10]) { value in
                                AxisValueLabel { Text(value.as(Int.self).map { $0 == 0 ? "Now" : "\($0)y" } ?? "") }
                            }
                        }
                        .frame(height: 140)
                        .redacted(reason: settings.hideNetworth ? .placeholder : [])
                    }
                    .card()
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Rental income") {
                        Button("Add") { addingIncome = true }
                    }
                    let incomes = (property.rentalIncomes ?? []).sorted { $0.date > $1.date }
                    if incomes.isEmpty {
                        Text("Record rent you receive to track this property's income.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .card()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(incomes.enumerated()), id: \.element.id) { index, income in
                                HoldingRow(icon: "arrow.down.left", tint: Theme.positive, title: income.notes ?? "Rent",
                                           subtitle: income.date.formatted(date: .abbreviated, time: .omitted),
                                           amount: income.amount, currency: income.currency, amountColor: Theme.positive)
                                    .padding(.horizontal, Theme.spacing)
                                    .padding(.vertical, 8)
                                if index < incomes.count - 1 { Divider().padding(.leading, 64) }
                            }
                        }
                        .card(padding: 0)
                    }
                }
            }
            .padding()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DetailToolbar(name: property.name, edit: { editing = true }, delete: { modelContext.delete(property) })
        }
        .sheet(isPresented: $editing) {
            NavigationStack { PropertyForm(property: property) }
        }
        .sheet(isPresented: $addingIncome) {
            NavigationStack { RentalIncomeForm(property: property) }
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Liability

struct LiabilityDetailView: View {
    @Bindable var liability: Liability

    @Environment(\.modelContext) private var modelContext
    @State private var editing = false
    @State private var paying = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DetailHeader(icon: liability.type == .creditCard ? "creditcard.fill" : "doc.text.fill", tint: NetWorthCategory.liabilities.tint,
                             title: liability.name, subtitle: liability.type.rawValue,
                             amount: liability.balance, currency: liability.currency) {
                    if let dueDate = liability.dueDate {
                        Text("Due \(dueDate.formatted(date: .long, time: .omitted))")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(dueDate < .now ? Theme.negative : .secondary)
                    }
                }

                Button("Record payment") { paying = true }
                    .buttonStyle(.primary)

                if let utilization = liability.utilization, let limit = liability.creditLimit {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Credit used")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(utilization.formatted(.percent.precision(.fractionLength(0))))
                                .font(.body.weight(.semibold))
                                .monospacedDigit()
                        }
                        ProgressView(value: utilization)
                            .tint(utilization > 0.3 ? .orange : Theme.positive)
                        Text("of \(limit.money(liability.currency)) limit. Under 30% is best for your credit score.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .card()
                }

                StatGrid(items: [
                    ("Interest rate", liability.interestRate.map { "\($0.formatted(.number.precision(.fractionLength(0...2))))%" } ?? "—"),
                    ("Minimum payment", liability.minPayment?.money(liability.currency) ?? "—"),
                ])

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Payments")
                    let payments = liability.paymentHistory
                    if payments.isEmpty {
                        Text("Payments you record appear here and reduce the balance.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .card()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(payments.enumerated()), id: \.element.id) { index, payment in
                                HoldingRow(icon: "checkmark", tint: Theme.positive, title: payment.note ?? "Payment",
                                           subtitle: payment.date.formatted(date: .abbreviated, time: .omitted),
                                           amount: payment.amount, currency: payment.currency)
                                    .padding(.horizontal, Theme.spacing)
                                    .padding(.vertical, 8)
                                if index < payments.count - 1 { Divider().padding(.leading, 64) }
                            }
                        }
                        .card(padding: 0)
                    }
                }
            }
            .padding()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DetailToolbar(name: liability.name, edit: { editing = true }, delete: { modelContext.delete(liability) })
        }
        .sheet(isPresented: $editing) {
            NavigationStack { LiabilityForm(liability: liability) }
        }
        .sheet(isPresented: $paying) {
            NavigationStack { PaymentForm(liability: liability) }
        }
    }
}
