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
        Text("Pyry Lahtinen")
            .fontWeight(.heavy)
            .fontDesign(.rounded)
            .foregroundColor(.accentColor)
    }

    var version: String {
        guard let version = UIApplication.appVersion else {
            return ""
        }
        return "Version \(version)"
    }
    
    func openWebsite() {
        guard let url = URL(string: "https://pyry.info"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func openGithub() {
        guard let url = URL(string: "https://github.com/PyryL/enough"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func rateOnAppStore() {
        guard let url = URL(string: "https://itunes.apple.com/app/id6466716992?action=write-review"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("About"), footer: Text(version)) {
                    creator
                    Button(action: openGithub) {
                        Label("Source code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    .accessibilityAddTraits(.isLink)
                    .accessibilityRemoveTraits(.isButton)

                    Button(action: openWebsite) {
                        Label("Developer's website", systemImage: "globe")
                    }
                    .accessibilityAddTraits(.isLink)
                    .accessibilityRemoveTraits(.isButton)

                    Button(action: rateOnAppStore) {
                        Label("Rate on App Store", systemImage: "star")
                    }

                    NavigationLink(destination: ThirdPartyLicensesView()) {
                        Label("Third-party licenses", systemImage: "doc")
                    }
                }
                .foregroundColor(.primary)
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

struct ThirdPartyLicensesView: View {
    func openPage(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        Form {
            licenseItem(title: "Play symbol in the app icon",
                        license: "MIT license",
                        url: URL(string: "https://heroicons.com/")!)
        }
        .navigationTitle("Third-party licenses")
    }
    
    @ViewBuilder func licenseItem(title: String, license: String, url: URL) -> some View {
        Section {
            Label(title, systemImage: "photo")
            Label(license, systemImage: "doc")
            Button(action: { openPage(url) }) {
                Label(url.host() ?? url.absoluteString, systemImage: "globe")
            }
            .accessibilityAddTraits(.isLink)
            .accessibilityRemoveTraits(.isButton)
        }
    }
}

extension UIApplication {
    /// The version of the app, e.g. `1.2.3`.
    static var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

#Preview {
    SettingsView(isVisible: .constant(true))
}
