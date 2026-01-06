//
//  SettingsDetailView.swift
//  AppTemplateLite
//
//
//

import SwiftUI

struct SettingsDetailView: View {
    @Environment(AppServices.self) private var services
    @State private var viewModel = SettingsDetailViewModel()

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle(
                    "Share analytics",
                    isOn: Binding(
                        get: { viewModel.analyticsOptIn },
                        set: { viewModel.setAnalyticsOptIn($0, services: services) }
                    )
                )

                Toggle(
                    "Allow tracking (ATT)",
                    isOn: Binding(
                        get: { viewModel.trackingOptIn },
                        set: { viewModel.setTrackingOptIn($0, services: services) }
                    )
                )

                Button("Request tracking authorization") {
                    viewModel.requestTrackingAuthorization(services: services)
                }
                .disabled(!viewModel.trackingOptIn || viewModel.isProcessing || AppConfiguration.isMock)

                LabeledContent("Tracking status", value: viewModel.trackingStatusLabel)
            }

            if viewModel.needsRestart {
                Section {
                    Text("Restart the app to apply analytics changes.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if AppConfiguration.isMock {
                Section {
                    Text("Mock builds skip analytics and tracking SDKs.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings Detail")
        .onAppear {
            viewModel.onAppear(services: services)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView()
    }
    .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
