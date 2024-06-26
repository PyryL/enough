//
//  PhoneConnectionManager.swift
//  digitlessTimerWatch
//
//  Created by Pyry Lahtinen on 26.6.2024.
//

import Foundation
import WatchConnectivity
import os

class PhoneConnectionManager: NSObject, WatchConnectionProtocol, WCSessionDelegate {
    override init() {
        super.init()
        session.delegate = self
        session.activate()
        Logger.watch.log("watch init")
    }

    private let session = WCSession.default

    public var delegate: WatchConnectionDelegate? = nil

    func sendAction(_ action: WatchConnectionAction) {
        // cancel any pending transfers
        session.outstandingUserInfoTransfers.forEach { $0.cancel() }

        // check that sending is available
        guard session.activationState == .activated else {
            Logger.watch.log("watch could not send user info: \(self.session.activationState.rawValue)")
            return
        }

        // send the new info
        let userInfo: [String:Any] = [
            "action": action
        ]
        session.transferUserInfo(userInfo)
        Logger.watch.log("watch sent user info: \(userInfo)")
    }


    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        Logger.watch.log("watch received user info: \(userInfo)")
        if let action = userInfo["action"] as? WatchConnectionAction {
            delegate?.watchConnection(didReceive: action)
        }
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: (any Error)?) {
        Logger.watch.log("watch user info transfer finished: \(error)")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.watch.log("watch reachability: \(session.isReachable)")
    }

    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        Logger.watch.log("watch companion installation changed: \(session.isCompanionAppInstalled)")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        Logger.watch.log("watch session activated: \(activationState.rawValue) \(error)")
    }
}
