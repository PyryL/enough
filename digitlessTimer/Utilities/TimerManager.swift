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
    
    @Published private(set) var state: TimerState = .notStarted
    private var timerTargetDate: Date? = nil
    private var targetTimer: Timer? = nil
    
    private func loadVariablesFromStorage() {
        let sinceReference = UserDefaults.suite.double(forKey: UserDefaultsKeys.targetDate)
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
        timerTargetDate = Date(timeIntervalSinceNow: max(0.1, duration))
        state = .red
        let sinceReference = timerTargetDate!.timeIntervalSinceReferenceDate
        UserDefaults.suite.setValue(sinceReference, forKey: UserDefaultsKeys.targetDate)
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
        UserDefaults.suite.removeObject(forKey: UserDefaultsKeys.targetDate)
    }
    
    @objc private func appBecameActive(notification: NSNotification) {
        loadVariablesFromStorage()
    }
    
    enum TimerState {
        case notStarted, red, green
    }
}
