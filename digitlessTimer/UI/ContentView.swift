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
        #if os(iOS)
        .statusBarHidden()
        .overlay(SettingsButton(), alignment: .bottomTrailing)
        #endif
    }
}

struct SettingsButton: View {
    @State var settingsVisible: Bool = false

    var body: some View {
        Button(action: { settingsVisible.toggle() }) {
            Label("Settings", systemImage: "info.circle")
                .font(.headline)
                .labelStyle(.iconOnly)
                .padding()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $settingsVisible) {
            SettingsView(isVisible: $settingsVisible)
        }
    }
}

#Preview {
    ContentView()
}
