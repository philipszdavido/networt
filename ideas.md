# Ideas: making networt great

Ideas are grouped by theme and roughly ordered by priority within each group. Each one points at the code it affects.

## Status (2026-11-13)

Everything below is implemented, including widgets, iCloud sync, backup and restore, the `@Observable` migration, Dynamic Type throughout, and a full UI redesign on a shared design system (`views/design/Theme.swift`).

Changed from the plan:
- **Money is `Double`, not `Decimal`.** Moving to `Decimal` would mean rewriting every model and view.
- **No `VersionedSchema`.** All schema changes are lightweight-migratable. Migration was verified against a store from the original release, including relationships.
- **The "Overall" tab, bank card carousel and card colour setting were removed.** Home now covers net worth, history, allocation and recent activity.

Needs you:
- **iCloud sync and the widget's App Group** need the iCloud and App Groups capabilities on your Apple Developer team (a paid account for iCloud). Xcode registers them on the first device build with automatic signing.
- **iCloud sync is untested end to end**, because that needs signed builds on two devices with the same Apple ID.

Next ideas:
- **Fractional shares.** `Stock.quantity` is an `Int`; it needs a new `Double` property plus a migration.
- **Interactive widgets.** For example, tapping to refresh prices.

## 1. Trust first: security and correctness

A finance app has to be trustworthy before it can be useful.

- **The lock doesn't re-lock.** `EnterLockView` and `NewLockCodesView` set `settings.isLockCodeSet = true`, and that value is saved to UserDefaults. Nothing watches `scenePhase`, so once unlocked, the app stays unlocked across launches. Keep the unlocked state in memory only, and re-lock when the app moves to `.background`.
- **The PIN is stored in plain text** in UserDefaults (`GlobalSettings.lockCodes`). Move it to the Keychain as a salted hash. Add Face ID / Touch ID via `LocalAuthentication`, with the PIN as a fallback.
- **There are two `GlobalSettings` instances.** `NetworthView` creates its own, and the app root injects another. Use one source of truth: the `@EnvironmentObject`.
- **Money types are inconsistent.** `BankInfo.amount` and `Transaction.amount` are `Int`, so cents are lost. Everything else is `Double`, which drifts. Move all money to `Decimal`.
- **Conversions fail silently.** `CurrencyRates.convertCurrency` returns `nil`, and callers turn that into `?? 0.0`, so a holding in an unknown currency quietly counts as zero. Show a warning instead.
- **Rates go stale.** Rates are only fetched when the cache is empty. Refresh them daily or on pull-to-refresh, and show "rates as of <date>". `currencyRates.date` is already stored.

## 2. The killer feature: net worth over time

- Add a `NetWorthSnapshot` `@Model` with the date, the total, and a per-category breakdown in the base currency. Record one automatically each day on app open, and whenever a holding changes.
- Summary tab: a Swift Charts line chart with 1M / 6M / 1Y / All ranges, plus the change since last month as an amount and a %. Swift Charts is already used in `PieChartView` and `PropertyDetailView`.
- An assets-vs-liabilities stacked area chart over time.

## 3. Live prices

- **Stocks:** `Stock.price` is entered by hand. Add a quote provider (e.g. Finnhub, Alpha Vantage) with a refresh button and a cached last price.
- **Crypto:** `CoinHolding` holds a stored `Coin` snapshot, so `current_price` only changes when the coin is refetched. Add a "refresh prices" step that updates the stored `Coin`s using `CryptoViewModel`.
- Track cost basis for stocks and crypto, so the app can show unrealized gain/loss and allocation %.

## 4. Better data model

- Restore `BankInfo ↔ Transaction` as a real `@Relationship(deleteRule: .cascade)`; it is currently commented out. Make `Liability.payments` and `Property.rentalIncomes` explicit relationships too.
- When a payment is added, reduce the liability's balance automatically.
- Add a migration strategy (`VersionedSchema` + `SchemaMigrationPlan`) before changing the models further, so existing users' data survives updates.

## 5. Features users will love

- **Goals:** a target net worth, a debt-free date, and an emergency-fund target, each with a progress ring.
- **Debt payoff planner:** compare snowball and avalanche, using `Liability.interestRate` and `minPayment`. The data already exists.
- **Reminders:** local notifications before `Liability.dueDate`, plus a monthly "update your balances" nudge.
- **Widgets:** home-screen and lock-screen widgets showing net worth and its trend. They should respect `hideNetworth`.
- **iCloud sync:** a SwiftData + CloudKit `ModelConfiguration`. This requires every model property to be optional or to have a default.
- **Export and backup:** CSV and JSON export via `ShareLink` / `fileExporter`, and import from JSON.
- **Privacy:** blur the app's content in the app switcher, and add shake-to-hide.

## 6. Polish and UX

- **Onboarding:** pick a base currency, then add a first account, then set a PIN. Today the first screen is a PIN pad with no explanation.
- Empty states with a call to action on each tab.
- Haptics on the PIN pad.
- Dynamic Type support, and VoiceOver labels on amounts.
- Use `.currency(code:)` format styles everywhere instead of building `"\(currency) \(amount)"` strings.
- **Offline-first:** show the cached rates with a banner, instead of blocking the whole app on the "Loading from server…" screen in `NetworthView`.

## 7. Engineering health

- Delete the dead code: `ContentView.swift`, `Item.swift`, `NetworthView2.swift`, `TestWelcomeView.swift`, `views/UpdatesView2.swift`.
- Pull the net worth math out of the views (`SummaryView`, `MainView.calcNetworth`) into a single `NetWorthCalculator` that the Summary tab, the widgets and the snapshots all use.
- Unit tests for `CurrencyRates.convertCurrency`, the net worth aggregation, and the PIN flow. Make networking injectable (a protocol instead of `URLSession.shared`) so it can be tested.
- Move `CryptoViewModel` from `dataTask` to async/await with `@MainActor`. Consider migrating `ObservableObject` to `@Observable`.

## Suggested order

1. Trust first (section 1).
2. `NetWorthCalculator` and tests (section 7).
3. The net worth history chart (section 2).
4. Live prices (section 3).
5. Features and polish (sections 5 and 6).
