//
//  ContentView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var manager = TimerManager()
    
    var body: some View {
        ZStack {
            BackgroundColorView(manager: manager)
            
            if manager.state == .notStarted {
                SetTimerView(manager: manager)
            } else {
                StopButtonView(manager: manager)
            }
        }
        .statusBarHidden()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
