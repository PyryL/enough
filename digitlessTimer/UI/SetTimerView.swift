//
//  SetTimerView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct SetTimerView: View {
    @StateObject var manager: TimerManager
    @AppStorage(UserDefaultsKeys.timerHours, store: .suite) var hour: Int = 0
    @AppStorage(UserDefaultsKeys.timerMins, store: .suite) var minute: Int = 5
    @AppStorage(UserDefaultsKeys.timerSecs, store: .suite) var second: Int = 0
    
    @AccessibilityFocusState private var headerHasAccessibilityFocus: Bool

    private func startTimer() {
        let duration: TimeInterval = Double(60*60*hour + 60*minute + second)
        manager.startTimer(duration: duration)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Set timer")
                    #if os(iOS)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    #elseif os(watchOS)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    #endif
                    .accessibilityFocused($headerHasAccessibilityFocus)
                    .onAppear { headerHasAccessibilityFocus = true }
                    .accessibilityAddTraits(.isHeader)
                #if os(watchOS)
                Spacer()
                SettingsButton()
                #endif
            }
            Stack {
                PickerComponent(
                    title: "Hour",
                    range: 0..<24,
                    suffix: "h",
                    accessibilitySuffix: "hours",
                    selection: $hour)
                PickerComponent(
                    title: "Minute",
                    range: 0..<60,
                    suffix: "min",
                    accessibilitySuffix: "minutes",
                    selection: $minute)
                PickerComponent(
                    title: "Second",
                    range: 0..<60,
                    suffix: "s",
                    accessibilitySuffix: "seconds",
                    selection: $second)
            }
            Button(action: startTimer) {
                Text("Start")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    #if os(iOS)
                    .cornerRadius(12)
                    #elseif os(watchOS)
                    .clipShape(Capsule())
                    #endif
                    .padding()
            }
            .buttonStyle(.plain)
        }
    }

    private struct Stack<V:View>: View {
        @ViewBuilder var content: () -> (V)
        @Environment(\.dynamicTypeSize) var dynamicTypeSize

        var body: some View {
            if dynamicTypeSize > .xxxLarge {
                VStack {
                    content()
                }
            } else {
                #if os(iOS)
                HStack(spacing: 0) {
                    content()
                }
                #elseif os(watchOS)
                HStack {
                    content()
                }
                #endif
            }
        }
    }
}

struct PickerComponent: View {
    let title: String
    let range: Range<Int>
    let suffix: String
    let accessibilitySuffix: String
    @Binding var selection: Int

    private func label(_ i: Int) -> String {
        #if os(iOS)
        return "\(i) \(suffix)"
        #elseif os(watchOS)
        return "\(i)"
        #endif
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(range, id: \.self) { i in
                Text(label(i))
                    .tag(i)
                    #if os(iOS)
                    .font(.body)
                    #endif
                    .accessibilityLabel("\(i) \(accessibilitySuffix)")
            }
        }
        .modifier(DynamicSizingModifiers())
    }

    private struct DynamicSizingModifiers: ViewModifier {
        @Environment(\.dynamicTypeSize) var dynamicTypeSize

        func body(content: Content) -> some View {
            if dynamicTypeSize > .xxxLarge {
                content
                #if os(iOS)
                    .pickerStyle(.menu)
                #elseif os(watchOS)
                    .pickerStyle(.inline)
                #endif
            } else {
                content
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    SetTimerView(manager: TimerManager())
}
