import SwiftUI
import DesignSystem

struct TemplateFormProgressView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var isLoading = false

    var body: some View {
        DSScreen(title: "Template", scrollDismissesKeyboard: .interactively) {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSSection(title: "Create your profile", subtitle: "Short form with clear actions.") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        DSTextField(
                            placeholder: "Full name",
                            text: $name,
                            autocapitalization: .words,
                            style: .underline
                        )
                        DSTextField(
                            placeholder: "Email address",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never,
                            style: .underline
                        )
                    }
                }

                if isLoading {
                    ProgressView("Saving...")
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                DSButton.cta(title: "Continue", isLoading: isLoading) {
                    isLoading.toggle()
                }
                DSButton.link(title: "Skip for now") { }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TemplateFormProgressView()
    }
}
