//
//  PreventSleepModifier.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct PreventSleepModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

extension View {
    func preventSleep() -> some View {
        self.modifier(PreventSleepModifier())
    }
}

struct PreventSleepModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, world!")
            .preventSleep()
    }
}
