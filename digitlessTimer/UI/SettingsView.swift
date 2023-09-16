//
//  SettingsView.swift
//  digitlessTimer
//
//  Created by Pyry Lahtinen on 16.9.2023.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isVisible: Bool
    
    var creator: Text {
        Text("Created by ") +
        Text("Pyry Lahtinen").bold().foregroundColor(.accentColor)
    }
    
    func openWebsite() {
        guard let url = URL(string: "https://pyry.info"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func rateOnAppStore() {
        // TODO: app id links to EFiCa
        guard let url = URL(string: "https://itunes.apple.com/app/id1524798779?action=write-review"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("About")) {
                    creator
                    Button(action: openWebsite) {
                        Label("Visit website", systemImage: "globe")
                    }
                    Button(action: rateOnAppStore) {
                        Label("Rate on App Store", systemImage: "star")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isVisible = false }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isVisible: .constant(true))
    }
}
