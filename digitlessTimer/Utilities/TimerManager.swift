//
//  TimerManager.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

class TimerManager: ObservableObject, WatchConnectionDelegate {
    init() {
        #if os(iOS)
        watchConnection = WatchConnectionManager()
        #elseif os(watchOS)
        watchConnection = PhoneConnectionManager()
        #endif
        watchConnection.delegate = self

        loadVariablesFromStorage()

        #if os(iOS)
        let notificationName = UIApplication.didBecomeActiveNotification
        #elseif os(watchOS)
        let notificationName = WKApplication.didBecomeActiveNotification
        #endif
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: notificationName,
            object: nil)
    }
    
    @Published private(set) var state: TimerState = .notStarted
    private var timerTargetDate: Date? = nil
    private var targetTimer: Timer? = nil

    private var watchConnection: WatchConnectionProtocol

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
        let date = Date(timeIntervalSinceNow: max(0.1, duration))
        startTimer(date: date, isFromOtherDevice: false)
    }

    /// - Parameter isFromOtherDevice: `true` if the commands originates from another device (Watch or iPhone).
    private func startTimer(date: Date, isFromOtherDevice: Bool) {
        let isAlreadyPassed = date.timeIntervalSinceNow < 0
        timerTargetDate = date
        state = isAlreadyPassed ? .green : .red
        UserDefaults.suite.setValue(date.timeIntervalSinceReferenceDate,
                                    forKey: UserDefaultsKeys.targetDate)
        if !isAlreadyPassed {
            setTimerForTarget()
        }
        if !isFromOtherDevice {
            watchConnection.sendAction(.timerStarted(endDate: date))
        }
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
    
    /// - Parameter isFromOtherDevice: `true` if the commands originates from another device (Watch or iPhone).
    func resetTimer(isFromOtherDevice: Bool) {
        targetTimer?.invalidate()
        targetTimer = nil
        timerTargetDate = nil
        state = .notStarted
        UserDefaults.suite.removeObject(forKey: UserDefaultsKeys.targetDate)
        if !isFromOtherDevice {
            watchConnection.sendAction(.timerStopped)
        }
    }
    
    @objc private func appBecameActive(notification: NSNotification) {
        loadVariablesFromStorage()
    }

    func watchConnection(didReceive action: WatchConnectionAction) {
        switch action {
        case .timerStarted(let endDate):
            startTimer(date: endDate, isFromOtherDevice: true)
        case .timerStopped:
            resetTimer(isFromOtherDevice: true)
        }
    }

    enum TimerState {
        case notStarted, red, green
    }
}
