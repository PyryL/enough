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
        switch manager.state {
        case .notStarted:
            SetTimerView(manager: manager)
        case .green, .red:
            ColorView(manager: manager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
