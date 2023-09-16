//
//  SetTimerView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct SetTimerView: View {
    @StateObject var manager: TimerManager
    @State var hour: Int = 0
    @State var minute: Int = 5
    @State var second: Int = 0
    
    private func startTimer() {
        let duration: TimeInterval = Double(60*60*hour + 60*minute + second)
        manager.startTimer(duration: duration)
    }
    
    var body: some View {
        VStack {
            Text("Set timer")
                .font(.system(.title, design: .rounded, weight: .semibold))
            HStack {
                PickerComponent(title: "Hour", range: 0..<24, suffix: "h", selection: $hour)
                PickerComponent(title: "Minute", range: 0..<59, suffix: "min", selection: $minute)
                PickerComponent(title: "Second", range: 0..<59, suffix: "s", selection: $second)
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
    @Binding var selection: Int
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(range, id: \.self) { i in
                Text("\(i) \(suffix)").tag(i)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 100)
    }
}

struct SetTimerView_Previews: PreviewProvider {
    static var previews: some View {
        SetTimerView(manager: TimerManager())
    }
}
