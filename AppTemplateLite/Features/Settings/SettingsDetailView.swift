//
//  SettingsDetailView.swift
//  AppTemplateLite
//
//
//

import SwiftUI

struct SettingsDetailView: View {
    @State private var analyticsEnabled = true
    @State private var hapticsEnabled = true
    @State private var soundEnabled = true

    var body: some View {
        Form {
            Section("Preferences") {
                Toggle("Analytics", isOn: $analyticsEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                Toggle("Sound effects", isOn: $soundEnabled)
            }

            Section {
                Text("This view is a placeholder for real settings. Wire toggles to FeatureFlags or user defaults as needed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings Detail")
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
}
