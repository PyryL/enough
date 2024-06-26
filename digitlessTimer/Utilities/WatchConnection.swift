//
//  WatchConnection.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 26.6.2024.
//

import Foundation
import WatchConnectivity

protocol WatchConnectionProtocol {
    var delegate: WatchConnectionDelegate? { get set }
    func sendAction(_ action: WatchConnectionAction)
}

protocol WatchConnectionDelegate {
    func watchConnection(didReceive action: WatchConnectionAction)
}

enum WatchConnectionAction {
    case timerStarted(endDate: Date)
    case timerStopped
}
