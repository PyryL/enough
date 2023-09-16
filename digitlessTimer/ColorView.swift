//
//  ColorView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct ColorView: View {
    @ObservedObject var manager: TimerManager
    
    var color: Color {
        switch manager.state {
        case .green:
            return Color.green
        case .red:
            return Color.red
        case .notStarted:
            return Color.gray      // not visible to user
        }
    }
    
    var body: some View {
        color
            .ignoresSafeArea()
            .overlay(stopButton)
    }
    
    var stopButton: some View {
        Button(action: manager.resetTimer) {
            Image(systemName: "pause.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black.opacity(0.2))
                .padding()
        }
        .buttonStyle(.plain)
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorView(manager: TimerManager(isGreen: true))
    }
}
