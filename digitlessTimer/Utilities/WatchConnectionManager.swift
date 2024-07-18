//
//  WatchConnectionManager.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 26.6.2024.
//

import Foundation
import WatchConnectivity
import os

class WatchConnectionManager: NSObject, WatchConnectionProtocol, WCSessionDelegate {
    override init() {
        super.init()
        session.delegate = self
        session.activate()
        Logger.watch.log("ios init")
    }

    private let session = WCSession.default

    public var delegate: WatchConnectionDelegate? = nil

    public func sendAction(_ action: WatchConnectionAction) {
        // cancel any pending transfers
        session.outstandingUserInfoTransfers.forEach { $0.cancel() }

        // check that sending is available
        guard session.activationState == .activated else {
            Logger.watch.log("ios could not send user info: \(self.session.activationState.rawValue)")
            return
        }

        // send the new info
        let actionData: Data
        do {
            actionData = try JSONEncoder().encode(action)
        } catch {
            Logger.watch.log("ios could not encode action: \(error)")
            return
        }
        let userInfo = [
            "action": actionData
        ]
        session.transferUserInfo(userInfo)
        Logger.watch.log("ios sent action: \(actionData, privacy: .public)")
    }


    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        Logger.watch.log("ios received user info: \(userInfo, privacy: .public)")
        if let actionData = userInfo["action"] as? Data,
           let action = try? JSONDecoder().decode(WatchConnectionAction.self, from: actionData) {
            Logger.watch.log("ios received action: \(action, privacy: .public)")
            delegate?.watchConnection(didReceive: action)
        }
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: (any Error)?) {
        Logger.watch.log("ios user info transfer finished: \(error)")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.watch.log("ios reachability: \(session.isReachable)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Logger.watch.log("ios watch state: \(session.isPaired) \(session.isWatchAppInstalled)")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        Logger.watch.log("ios session activated: \(activationState.rawValue) \(error) and \(session.isPaired) \(session.isWatchAppInstalled) \(session.isReachable)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.watch.log("ios session inactivated")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.watch.log("ios session deactivated")
    }
}
