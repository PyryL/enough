//
//  ContentView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var manager = TimerManager()
    @State var settingsVisible: Bool = false
    
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
        .overlay(settingsButton, alignment: .bottomTrailing)
        .sheet(isPresented: $settingsVisible) {
            SettingsView(isVisible: $settingsVisible)
        }
    }
    
    var settingsButton: some View {
        Button(action: { settingsVisible.toggle() }) {
            Label("Settings", systemImage: "info.circle")
                .font(.headline)
                .labelStyle(.iconOnly)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
