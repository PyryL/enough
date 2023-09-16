//
//  StopButtonView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct StopButtonView: View {
    @ObservedObject var manager: TimerManager
    
    var body: some View {
        Button(action: manager.resetTimer) {
            Image(systemName: "pause.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black.opacity(0.2))
                .padding()
        }
        .buttonStyle(.plain)
        .preventSleep()
    }
}

struct StopButtonView_Previews: PreviewProvider {
    static var previews: some View {
        StopButtonView(manager: TimerManager())
    }
}
