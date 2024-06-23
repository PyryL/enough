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
            Text("Set timer")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .accessibilityFocused($headerHasAccessibilityFocus)
                .onAppear { headerHasAccessibilityFocus = true }
                .accessibilityAddTraits(.isHeader)
            HStack {
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
                    .cornerRadius(12)
                    .padding()
            }
            .buttonStyle(.plain)
        }
    }
}

struct PickerComponent: View {
    let title: String
    let range: Range<Int>
    let suffix: String
    let accessibilitySuffix: String
    @Binding var selection: Int
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(range, id: \.self) { i in
                Text("\(i) \(suffix)")
                    .tag(i)
                    .accessibilityLabel("\(i) \(accessibilitySuffix)")
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 100)
    }
}

#Preview {
    SetTimerView(manager: TimerManager())
}
