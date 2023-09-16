//
//  UserDefaults.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import Foundation

extension UserDefaults {
    /// Storage suite to use.
    static let suite = UserDefaults.standard
}

class UserDefaultsKeys {
    /// Value of this key should be `Double` (time interval since reference date).
    static let targetDate: String = "timerTargetDate"
}
