# Design System Recipes

These snippets show how to assemble common layouts using the DesignSystem components and tokens.

## 1) List + Hero + CTA
```swift
DSScreen(title: "Template") {
    VStack(alignment: .leading, spacing: DSSpacing.xl) {
        DSHeroCard(tilt: -2) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                    Spacer()
                    TagBadge(text: "Featured")
                }
                Text("Hero headline")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                Text("Short supporting copy.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
        }

        DSSection(title: "Quick actions") {
            DSListCard {
                DSListRow(title: "First action", subtitle: "Primary task", leadingIcon: "bolt.fill") {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
                Divider()
                DSListRow(title: "Second action", subtitle: "Next step", leadingIcon: "checkmark.circle") {
                    DSIconButton(icon: "chevron.right", style: .secondary, size: .small)
                }
            }
        }

        DSButton.cta(title: "Primary CTA") { }
    }
}
```

## 2) Form + Progress
```swift
DSScreen(title: "Template", scrollDismissesKeyboard: .interactively) {
    VStack(alignment: .leading, spacing: DSSpacing.xl) {
        DSSection(title: "Create your profile") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                DSTextField(placeholder: "Full name", text: $name, autocapitalization: .words, style: .underline)
                DSTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress, style: .underline)
            }
        }

        ProgressView("Saving...")
            .font(.bodySmall())
            .foregroundStyle(Color.textSecondary)

        DSButton.cta(title: "Continue", isLoading: isLoading) { }
    }
}
```

## 3) Settings + Toggles
```swift
DSScreen(title: "Template") {
    DSSection(title: "Preferences") {
        DSListCard {
            DSListRow(title: "Notifications", subtitle: "Stay updated", leadingIcon: "bell.fill") {
                GlassToggle(isOn: $notificationsEnabled)
            }
            Divider()
            DSListRow(title: "Share analytics", subtitle: "Improve the experience", leadingIcon: "chart.line.uptrend.xyaxis") {
                GlassToggle(isOn: $analyticsEnabled)
            }
        }
    }
}
```

## 4) Paywall + Plans
```swift
DSScreen(title: "Template") {
    DSHeroCard(tilt: -2) {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                Spacer()
                TagBadge(text: "Pro")
            }
            Text("Upgrade to Pro")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            Text("Unlock advanced features.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
        }
    }

    DSSection(title: "Choose a plan") {
        VStack(spacing: DSSpacing.sm) {
            planCard(title: "Monthly", price: "$9.99", id: "monthly")
            planCard(title: "Yearly", price: "$79.99", id: "yearly")
        }
    }

    DSButton.cta(title: "Unlock Pro") { }
}
```
