//
//  StopButtonView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct StopButtonView: View {
    @ObservedObject var manager: TimerManager
    @State private var isPressed: Bool = false
    
    var body: some View {
        Image(systemName: "pause.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundColor(.black.opacity(0.2))
            .padding()
            .onLongPressGesture(
                minimumDuration: manager.state == .green ? .leastNormalMagnitude : 1.5,
                perform: manager.resetTimer,
                onPressingChanged: { isPressed = $0 })
            .preventSleep()
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .animation(.bouncy, value: isPressed)
    }
}

#Preview {
    StopButtonView(manager: TimerManager())
}
