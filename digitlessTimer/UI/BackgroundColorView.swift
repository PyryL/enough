//
//  BackgroundColorView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct BackgroundColorView: View {
    @ObservedObject var manager: TimerManager
    
    var color: Color {
        switch manager.state {
        case .green:
            return Color.green
        case .red:
            return Color.red
        case .notStarted:
            return Color(uiColor: .systemBackground)
        }
    }
    
    var body: some View {
        color
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2), value: color)
    }
}

struct BackgroundColorView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColorView(manager: TimerManager())
    }
}
