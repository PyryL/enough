//
//  WatchConnectionManager.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 26.6.2024.
//

import Foundation
import WatchConnectivity

class WatchConnectionManager: NSObject, WatchConnectionProtocol, WCSessionDelegate {
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }

    private let session = WCSession.default

    public var delegate: WatchConnectionDelegate? = nil

    public func sendAction(_ action: WatchConnectionAction) {
        // cancel any pending transfers
        session.outstandingUserInfoTransfers.forEach { $0.cancel() }

        // check that sending is available
        guard session.activationState == .activated else {
            print("could not send user info: \(session.activationState)")
            return
        }

        // send the new info
        let userInfo: [String:Any] = [
            "action": action
        ]
        session.transferUserInfo(userInfo)
    }


    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("ios received info \(userInfo)")
        if let action = userInfo["action"] as? WatchConnectionAction {
            delegate?.watchConnection(didReceive: action)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("session activated: \(activationState == .activated) \(error as Any)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session inactivated")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("session deactivated")
    }
}
