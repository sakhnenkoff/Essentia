//
//  AuthView.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import SwiftfulAuthUI
import DesignSystem

struct AuthView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var viewModel = AuthViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Sign in")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("Connect your account to sync data and unlock premium features.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DSSpacing.smd) {
                Button {
                    viewModel.signInApple(services: services, session: session)
                } label: {
                    SignInAppleButtonView(
                        type: .signIn,
                        style: .black,
                        cornerRadius: 12
                    )
                    .frame(height: 55)
                    .frame(maxWidth: 420)
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.signInGoogle(services: services, session: session)
                } label: {
                    SignInGoogleButtonView(
                        type: .signIn,
                        backgroundColor: .googleRed,
                        cornerRadius: 12
                    )
                    .frame(height: 55)
                    .frame(maxWidth: 420)
                }
                .buttonStyle(.plain)

                DSButton(
                    title: "Continue as Guest",
                    style: .secondary
                ) {
                    viewModel.signInAnonymously(services: services, session: session)
                }
            }
            .disabled(viewModel.isLoading)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if viewModel.isLoading {
                ProgressView("Signing in...")
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .padding(.top, DSSpacing.xxlg)
    }
}

#Preview {
    AuthView()
        .environment(AppServices(configuration: .mock(isSignedIn: false)))
        .environment(AppSession())
}
