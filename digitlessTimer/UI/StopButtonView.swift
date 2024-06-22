//
//  StopButtonView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI
import Combine  // for AnyCancellable

struct StopButtonView: View {
    @ObservedObject var manager: TimerManager
    @State private var pressStart: Date? = nil
    @State private var pressPercentage: Double = 0
    @State private var pressTimer: AnyCancellable? = nil
    @State private var showLongPressGuide: Bool = false

    private func pressChanged(_ isPressed: Bool) {
        if isPressed {
            pressStart = .now
            let secPerFrame = 1.0 / Double(UIScreen.main.maximumFramesPerSecond)
            pressTimer = Timer
                .publish(every: secPerFrame, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    guard let pressStart else { return }
                    let duration = -pressStart.timeIntervalSinceNow
                    pressPercentage = min(1.0, duration / minimumDuration)
                }
        } else {
            if let pressStart, -pressStart.timeIntervalSinceNow < minimumDuration {
                showLongPressGuide = true
            } else {
                showLongPressGuide = false
            }
            pressTimer?.cancel()
            pressTimer = nil
            pressStart = nil
            pressPercentage = 0
        }
    }

    private var minimumDuration: Double {
        manager.state == .green ? .leastNormalMagnitude : 0.7
    }

    private var scale: CGFloat {
        guard pressStart != nil else {
            return 1.0
        }
        guard manager.state != .green else {
            return 0.9
        }
        return 0.2 * pressPercentage + 0.8
    }

    var body: some View {
        Image(systemName: "pause.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundColor(.black.opacity(0.2))
            .padding()
            .onLongPressGesture(
                minimumDuration: minimumDuration,
                perform: manager.resetTimer,
                onPressingChanged: pressChanged)
            .scaleEffect(scale)
            .animation(.linear(duration: 0.2), value: pressPercentage)
            .overlay(LongPressGuide(manager: manager, isShown: $showLongPressGuide),
                     alignment: .bottom)
            .preventSleep()
    }
}

fileprivate struct LongPressGuide: View {
    @ObservedObject var manager: TimerManager
    @Binding var isShown: Bool
    @State private var hideTimer: Timer? = nil

    var body: some View {
        Text("Press and hold to cancel the timer")
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .offset(y: 50)
            .opacity(isShown && manager.state != .green ? 1.0 : 0.0)
            .animation(.easeInOut, value: isShown)
            .onChangePolyfill(value: isShown) {
                guard isShown else { return }
                hideTimer?.invalidate()
                hideTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                    isShown = false
                }
            }
    }
}

fileprivate extension View {
    func onChangePolyfill<V:Equatable>(value: V, action: @escaping ()->()) -> some View {
        if #available(iOS 18, *) {
            return self.onChange(of: value, action)
        } else {
            return self.onChange(of: value, perform: { _ in action() })
        }
    }
}

#Preview {
    StopButtonView(manager: TimerManager())
}
