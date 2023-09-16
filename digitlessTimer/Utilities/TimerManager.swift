//
//  TimerManager.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

class TimerManager: ObservableObject {
    init() {
        loadVariablesFromStorage()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    #if DEBUG
    init(isGreen: Bool) {
        state = isGreen ? .green : .red
        timerTargetDate = Date(timeIntervalSinceNow: isGreen ? -60 : 60)
    }
    #endif
    
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey: String = "timerTargetDate"
    
    @Published private(set) var state: TimerState = .notStarted
    private var timerTargetDate: Date? = nil
    private var targetTimer: Timer? = nil
    
    private func loadVariablesFromStorage() {
        let sinceReference = userDefaults.double(forKey: userDefaultsKey)
        if sinceReference > 0 {
            timerTargetDate = Date(timeIntervalSinceReferenceDate: sinceReference)
            state = timerTargetDate!.timeIntervalSinceNow < 0 ? .green : .red
        } else {
            timerTargetDate = nil
            state = .notStarted
        }
        setTimerForTarget()
    }
    
    func startTimer(duration: TimeInterval) {
        timerTargetDate = Date(timeIntervalSinceNow: duration)
        state = .red
        userDefaults.setValue(timerTargetDate!.timeIntervalSinceReferenceDate, forKey: userDefaultsKey)
        setTimerForTarget()
    }
    
    private func setTimerForTarget() {
        targetTimer?.invalidate()
        targetTimer = nil
        guard let timerTargetDate else {
            return
        }
        let secondsToGo = timerTargetDate.timeIntervalSinceNow
        guard secondsToGo > 0 else {
            return
        }
        targetTimer = Timer.scheduledTimer(withTimeInterval: secondsToGo, repeats: false) { _ in
            self.targetTimer?.invalidate()
            self.targetTimer = nil
            self.state = .green
        }
    }
    
    func resetTimer() {
        timerTargetDate = nil
        state = .notStarted
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
    
    @objc private func appBecameActive(notification: NSNotification) {
        loadVariablesFromStorage()
    }
    
    enum TimerState {
        case notStarted, red, green
    }
}
