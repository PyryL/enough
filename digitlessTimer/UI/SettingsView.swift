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
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        return "Version \(version)"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("About"), footer: Text(version)) {
                    creator

                    Link(destination: URL(string: "https://github.com/PyryL/enough")!) {
                        Label("Source code on GitHub",
                              systemImage: "chevron.left.forwardslash.chevron.right")
                    }

                    Link(destination: URL(string: "https://pyry.info")!) {
                        Label("Developer's website", systemImage: "globe")
                    }

                    Link(destination: URL(string: "https://itunes.apple.com/app/id6466716992?action=write-review")!) {
                        Label("Rate on App Store", systemImage: "star")
                    }

                    NavigationLink(destination: ThirdPartyLicensesView()) {
                        Label("Third-party licenses", systemImage: "doc")
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isVisible = false }) {
                        Text("Done")
                    }
                }
            }
            #endif
        }
    }
}

struct ThirdPartyLicensesView: View {
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
            Link(destination: url) {
                Label(url.host() ?? url.absoluteString, systemImage: "globe")
            }
        }
    }
}

#Preview {
    SettingsView(isVisible: .constant(true))
}
