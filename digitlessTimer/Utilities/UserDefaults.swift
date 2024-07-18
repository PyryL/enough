//
//  UserDefaults.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import Foundation

extension UserDefaults {
    /// Storage suite to use.
    static var suite: UserDefaults {
        guard let suite = UserDefaults(suiteName: "group.info.pyry.apps.digitlessTimer") else {
            print("UserDefaults suite creation failed")
            return .standard
        }
        return suite
    }
}

class UserDefaultsKeys {
    /// Value of this key should be `Double` (time interval since reference date).
    static let targetDate: String = "timerTargetDate"
    
    /// Value of this key should be `Int`.
    static let timerHours: String = "timerHours"
    
    /// Value of this key should be `Int`.
    static let timerMins: String = "timerMinutes"
    
    /// Value of this key should be `Int`.
    static let timerSecs: String = "timerSeconds"
}
