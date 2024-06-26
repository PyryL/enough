//
//  Logger.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 26.6.2024.
//

import Foundation
import os

extension Logger {
    static let watch = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "watch")
}
