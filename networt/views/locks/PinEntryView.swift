//
//  PinEntryView.swift
//  networt
//

import SwiftUI

/// Title, dots and keypad. Calls `onComplete` once four digits are entered, then clears itself.
struct PinEntryView<Accessory: View>: View {
    var title: String
    var message: String
    /// Bump this to play the error haptic and shake the dots.
    var failures: Int = 0
    var onComplete: (String) -> Void
    @ViewBuilder var accessory: Accessory

    static var length: Int { 4 }

    @State private var digits: [Character] = []
    @State private var shake: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 56, height: 56)
                .background(Color.accentColor.opacity(0.12), in: Circle())
                .padding(.bottom, 20)

            Text(title)
                .font(.title2.weight(.semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(failures > 0 ? Theme.negative : .secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
                .padding(.horizontal)

            HStack(spacing: 18) {
                ForEach(0..<Self.length, id: \.self) { index in
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.35), lineWidth: 1.5)
                        .background(Circle().fill(index < digits.count ? Color.primary : .clear))
                        .frame(width: 14, height: 14)
                }
            }
            .modifier(ShakeEffect(animatableData: shake))
            .padding(.vertical, 36)
            .accessibilityElement()
            .accessibilityLabel("\(digits.count) of \(Self.length) digits entered")

            Spacer()

            keypad
                .padding(.horizontal, 40)

            accessory
                .frame(height: 44)
                .padding(.top, 12)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .screenBackground()
        .sensoryFeedback(.selection, trigger: digits.count)
        .sensoryFeedback(.error, trigger: failures)
        .onChange(of: failures) {
            withAnimation(.default) { shake += 1 }
        }
    }

    var keypad: some View {
        Grid(horizontalSpacing: 24, verticalSpacing: 16) {
            ForEach([["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]], id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { key($0) }
                }
            }
            GridRow {
                Color.clear.frame(width: 76, height: 76)
                key("0")
                Button {
                    _ = digits.popLast()
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .frame(width: 76, height: 76)
                }
                .foregroundStyle(.primary)
                .opacity(digits.isEmpty ? 0 : 1)
                .accessibilityLabel("Delete")
            }
        }
    }

    func key(_ digit: String) -> some View {
        Button {
            append(Character(digit))
        } label: {
            Text(digit)
                .font(.system(.title, design: .rounded).weight(.medium))
                .frame(width: 76, height: 76)
                .background(Color(.secondarySystemGroupedBackground), in: Circle())
        }
        .buttonStyle(KeyButtonStyle())
    }

    func append(_ digit: Character) {
        guard digits.count < Self.length else { return }
        digits.append(digit)

        if digits.count == Self.length {
            let pin = String(digits)
            // Let the last dot fill before clearing.
            Task {
                try? await Task.sleep(for: .milliseconds(120))
                digits = []
                onComplete(pin)
            }
        }
    }
}

extension PinEntryView where Accessory == EmptyView {
    init(title: String, message: String, failures: Int = 0, onComplete: @escaping (String) -> Void) {
        self.init(title: title, message: message, failures: failures, onComplete: onComplete) { EmptyView() }
    }
}

private struct KeyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 4), y: 0))
    }
}

#Preview {
    PinEntryView(title: "Enter PIN", message: "Unlock to see your net worth", onComplete: { _ in })
}
