//
//  TimerManager.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI
import WidgetKit
#if os(iOS)
import os
#endif

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
        setTimerForTarget(timeintervalSinceNow: timerTargetDate?.timeIntervalSinceNow ?? -1)
    }
    
    func startTimer(duration: TimeInterval) {
        let date = Date(timeIntervalSinceNow: max(0.1, duration))
        startTimer(date: date, isFromOtherDevice: false)
    }

    /// - Parameter isFromOtherDevice: `true` if the commands originates from another device (Watch or iPhone).
    private func startTimer(date: Date, isFromOtherDevice: Bool) {
        let timeintervalSinceNow = date.timeIntervalSinceNow
        let isAlreadyPassed = timeintervalSinceNow < 0
        timerTargetDate = date
        state = isAlreadyPassed ? .green : .red
        UserDefaults.suite.setValue(date.timeIntervalSinceReferenceDate,
                                    forKey: UserDefaultsKeys.targetDate)
        if !isAlreadyPassed {
            setTimerForTarget(timeintervalSinceNow: timeintervalSinceNow)
        }
        if !isFromOtherDevice {
            watchConnection.sendAction(.timerStarted(endDate: date))
        }
        WidgetCenter.shared.reloadAllTimelines()
        #if os(iOS)
        Logger.watch.log("ios finished handling action \(date, privacy: .public); \(isAlreadyPassed) \(isFromOtherDevice)")
        #endif
    }

    private func setTimerForTarget(timeintervalSinceNow: Double) {
        targetTimer?.invalidate()
        targetTimer = nil
        #if os(iOS)
        Logger.watch.log("ios invalidating timer; \(timeintervalSinceNow)")
        #endif
        guard timeintervalSinceNow > 0 else {
            return
        }
        #if os(iOS)
        Logger.watch.log("ios setting timer \(timeintervalSinceNow)")
        #endif
        targetTimer = Timer.scheduledTimer(withTimeInterval: timeintervalSinceNow, repeats: false) { _ in
            self.targetTimer?.invalidate()
            self.targetTimer = nil
            self.state = .green
            #if os(iOS)
            Logger.watch.log("ios turning green")
            #endif
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
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @objc private func appBecameActive(notification: NSNotification) {
        loadVariablesFromStorage()
    }

    func watchConnection(didReceive action: WatchConnectionAction) {
        #if os(iOS)
        Logger.watch.log("ios handling action \(action, privacy: .public)")
        #endif
        DispatchQueue.main.async {
            switch action {
            case .timerStarted(let endDate):
                self.startTimer(date: endDate, isFromOtherDevice: true)
            case .timerStopped:
                self.resetTimer(isFromOtherDevice: true)
            }
        }
    }

    enum TimerState {
        case notStarted, red, green
    }
}
