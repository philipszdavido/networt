//
//  SettingsView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/7/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(GlobalSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @State private var notificationsDenied = false
    @State private var importing = false
    @State private var pendingRestore: Backup?
    @State private var restoreError: String?
    @State private var restoredCount: Int?

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            Form {
                Section("General") {
                    NavigationLink {
                        CurrencyPicker(selection: $settings.currency)
                    } label: {
                        SettingsLabel("Main currency", icon: "dollarsign", tint: .green) {
                            Text(settings.currency.uppercased())
                        }
                    }
                    NavigationLink {
                        RatesView()
                    } label: {
                        SettingsLabel("Exchange rates", icon: "arrow.left.arrow.right", tint: .blue) {
                            if let date = settings.ratesDate {
                                Text(date.formatted(.dateTime.day().month()))
                            }
                        }
                    }
                }

                Section("Appearance") {
                    Picker(selection: $settings.fontDesign) {
                        Text("Default").tag(Font.Design.default)
                        Text("Rounded").tag(Font.Design.rounded)
                        Text("Serif").tag(Font.Design.serif)
                        Text("Mono").tag(Font.Design.monospaced)
                    } label: {
                        SettingsLabel("Font", icon: "textformat", tint: .indigo)
                    }
                    Toggle(isOn: $settings.hideNetworth) {
                        SettingsLabel("Hide amounts", icon: "eye.slash.fill", tint: .gray)
                    }
                    Toggle(isOn: $settings.showUpdates) {
                        SettingsLabel("Recent activity on Home", icon: "clock.fill", tint: .orange)
                    }
                }

                Section {
                    if Biometrics.isAvailable {
                        Toggle(isOn: $settings.useBiometrics) {
                            SettingsLabel("Unlock with \(Biometrics.label)", icon: Biometrics.label == "Touch ID" ? "touchid" : "faceid", tint: .green)
                        }
                    }
                    Button {
                        settings.resetPasscode()
                    } label: {
                        SettingsLabel("Change PIN", icon: "lock.rotation", tint: .blue)
                    }
                    .foregroundStyle(.primary)
                    Button {
                        settings.lock()
                    } label: {
                        SettingsLabel("Lock now", icon: "lock.fill", tint: .gray)
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Security")
                } footer: {
                    Text("The app locks whenever you leave it. Shake your phone to hide or show amounts.")
                }

                Section {
                    Toggle(isOn: Binding(get: { settings.remindersEnabled }, set: { enabled in Task { await setReminders(enabled) } })) {
                        SettingsLabel("Reminders", icon: "bell.badge.fill", tint: .red)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text(notificationsDenied
                         ? "Notifications are turned off for this app in iOS Settings."
                         : "Three days before a debt is due, and a monthly nudge to update your balances.")
                }

                Section {
                    Toggle(isOn: $settings.iCloudSync) {
                        SettingsLabel("iCloud sync", icon: "icloud.fill", tint: .cyan)
                    }
                } header: {
                    Text("iCloud")
                } footer: {
                    if settings.iCloudSync != settings.iCloudSyncActive {
                        Text("Close and reopen the app to \(settings.iCloudSync ? "start" : "stop") syncing.")
                            .foregroundStyle(.orange)
                    } else {
                        Text(settings.iCloudSync
                             ? "Your accounts sync to your other devices through your private iCloud database. Your PIN stays on this device."
                             : "Keep your accounts in sync across your iPhone and iPad.")
                    }
                }

                Section {
                    let exporter = DataExporter(context: modelContext, calculator: NetWorthCalculator(settings: settings))
                    ShareLink(item: exporter.backup(), preview: SharePreview("Net worth backup")) {
                        SettingsLabel("Back up", icon: "arrow.up.doc.fill", tint: .blue)
                    }
                    .foregroundStyle(.primary)
                    Button {
                        importing = true
                    } label: {
                        SettingsLabel("Restore from backup", icon: "arrow.down.doc.fill", tint: .blue)
                    }
                    .foregroundStyle(.primary)
                    ShareLink(item: exporter.csv(), preview: SharePreview("Net worth (CSV)")) {
                        SettingsLabel("Export spreadsheet", icon: "tablecells.fill", tint: .green)
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Data")
                } footer: {
                    Text("A backup holds every account, payment and your history. The spreadsheet lists each holding with its value in \(settings.currency.uppercased()).")
                }

                Section {
                    LabeledContent("Version", value: Bundle.main.appVersion)
                }
            }
            .navigationTitle("Settings")
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
                loadBackup(result)
            }
            .confirmationDialog(
                "Replace all data?",
                isPresented: Binding(get: { pendingRestore != nil }, set: { if !$0 { pendingRestore = nil } }),
                titleVisibility: .visible,
                presenting: pendingRestore
            ) { backup in
                Button("Replace with \(backup.itemCount) account\(backup.itemCount == 1 ? "" : "s")", role: .destructive) {
                    restore(backup)
                }
            } message: { backup in
                Text("Everything currently in the app\(settings.iCloudSyncActive ? " and on your synced devices" : "") will be replaced by the backup from \(backup.exportedAt.formatted(date: .abbreviated, time: .shortened)).")
            }
            .alert("Couldn't restore", isPresented: Binding(get: { restoreError != nil }, set: { if !$0 { restoreError = nil } })) {
                Button("OK") {}
            } message: {
                Text(restoreError ?? "")
            }
            .alert("Backup restored", isPresented: Binding(get: { restoredCount != nil }, set: { if !$0 { restoredCount = nil } })) {
                Button("OK") {}
            } message: {
                Text("\(restoredCount ?? 0) account(s) restored.")
            }
        }
    }

    func loadBackup(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            pendingRestore = try Backup.decode(try Data(contentsOf: url))
        } catch {
            restoreError = error.localizedDescription
        }
    }

    func restore(_ backup: Backup) {
        do {
            try backup.restore(into: modelContext)
            restoredCount = backup.itemCount
        } catch {
            restoreError = error.localizedDescription
        }
    }

    @MainActor
    func setReminders(_ enabled: Bool) async {
        if enabled {
            guard await Reminders.requestAuthorization() else {
                notificationsDenied = true
                return
            }
            notificationsDenied = false
            settings.remindersEnabled = true
            await Reminders.reschedule(liabilities: (try? modelContext.fetch(FetchDescriptor<Liability>())) ?? [])
        } else {
            settings.remindersEnabled = false
            Reminders.cancelAll()
        }
    }
}

/// The icon-in-a-rounded-square row label used throughout Settings.
struct SettingsLabel<Trailing: View>: View {
    var title: String
    var icon: String
    var tint: Color
    @ViewBuilder var trailing: Trailing

    init(_ title: String, icon: String, tint: Color, @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(tint.gradient, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            trailing
                .foregroundStyle(.secondary)
        }
    }
}

/// What one unit of each currency is worth in the main currency.
struct RatesView: View {
    @Environment(GlobalSettings.self) private var settings

    @State private var search = ""
    @State private var refreshing = false
    @State private var failed = false

    var codes: [String] {
        let all = settings.availableCurrencies.filter { $0 != settings.currency.lowercased() }
        guard !search.isEmpty else { return all }
        return all.filter { $0.localizedStandardContains(search) || settings.currencyName($0).localizedStandardContains(search) }
    }

    var body: some View {
        List {
            Section {
                ForEach(codes, id: \.self) { code in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("1 \(code.uppercased())").font(.body.weight(.medium))
                            Text(settings.currencyName(code)).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        if let value = CurrencyRates.convertCurrency(amount: 1, from: code, to: settings.currency, using: settings.currencyRates) {
                            Text(value.formatted(.currency(code: settings.currency.uppercased()).precision(.significantDigits(4))))
                                .monospacedDigit()
                        }
                    }
                }
            } footer: {
                if let date = settings.ratesDate {
                    Text("Rates from \(date.formatted(date: .long, time: .omitted)). They update automatically twice a day.")
                }
            }
        }
        .searchable(text: $search, prompt: "Currency")
        .refreshable { await refresh() }
        .navigationTitle("Exchange rates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if refreshing {
                    ProgressView()
                } else {
                    Button("Refresh", systemImage: "arrow.clockwise") { Task { await refresh() } }
                }
            }
        }
        .alert("Couldn't refresh rates", isPresented: $failed) {
            Button("OK") {}
        } message: {
            Text("Your saved rates are still in use.")
        }
    }

    func refresh() async {
        refreshing = true
        do {
            try await settings.refreshRates()
        } catch {
            failed = true
        }
        refreshing = false
    }
}

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: allModels, inMemory: true)
        .environment(GlobalSettings())
}
