import SwiftUI

struct BrandingColoursView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var accentColor: Color
    @State private var backgroundColor: Color

    init() {
        _accentColor = State(initialValue: ThemeManager.shared.accentColor)
        _backgroundColor = State(initialValue: ThemeManager.shared.backgroundColor)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                Text("Customise your app's colour palette. Changes apply live throughout the app.")
                    .font(.dmtBody(13))
                    .foregroundColor(.dmtMutedText)
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.top, AppTheme.paddingMedium)

                SettingsSection(title: "Accent Colour (Gold)") {
                    ColorPicker("Accent Colour", selection: $accentColor, supportsOpacity: false)
                        .foregroundColor(.dmtPrimaryText)
                        .font(.dmtBody(14))
                        .onChange(of: accentColor) { newColor in
                            themeManager.accentColor = newColor
                        }

                    HStack(spacing: AppTheme.paddingSmall) {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(accentColor)
                            .frame(width: 40, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                            )
                        Text("Used for highlights, active states, progress bars")
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtMutedText)
                    }
                }

                SettingsSection(title: "Background Colour") {
                    ColorPicker("Background Colour", selection: $backgroundColor, supportsOpacity: false)
                        .foregroundColor(.dmtPrimaryText)
                        .font(.dmtBody(14))
                        .onChange(of: backgroundColor) { newColor in
                            themeManager.backgroundColor = newColor
                        }

                    HStack(spacing: AppTheme.paddingSmall) {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(backgroundColor)
                            .frame(width: 40, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                            )
                        Text("Used for the main app background")
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtMutedText)
                    }
                }

                // Live preview
                SettingsSection(title: "Live Preview") {
                    VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                        HStack {
                            Text("Sample Card")
                                .font(.dmtBody(14))
                                .foregroundColor(.dmtPrimaryText)
                            Spacer()
                            Text("Active".uppercased())
                                .font(.dmtLabel(8))
                                .tracking(1)
                                .foregroundColor(accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(accentColor, lineWidth: AppTheme.borderWidth)
                                )
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color.dmtBorder).frame(height: 2)
                                Rectangle()
                                    .fill(LinearGradient(colors: [accentColor, accentColor.opacity(0.6)],
                                                         startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * 0.65, height: 2)
                            }
                        }
                        .frame(height: 2)

                        Text("65% Progress")
                            .font(.dmtBody(11))
                            .foregroundColor(.dmtMutedText)
                    }
                    .padding(AppTheme.paddingMedium)
                    .background(backgroundColor)
                    .cornerRadius(AppTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                    )
                }

                Button {
                    themeManager.resetToDefaults()
                    accentColor = themeManager.accentColor
                    backgroundColor = themeManager.backgroundColor
                } label: {
                    Text("Reset to Defaults".uppercased())
                        .font(.dmtLabel(9))
                        .tracking(1.5)
                        .foregroundColor(.dmtMutedText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.paddingMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                        )
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Spacer(minLength: AppTheme.paddingXL)
            }
        }
        .background(Color.dmtBackground.ignoresSafeArea())
        .navigationTitle("Branding Colours")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BrandingColoursView()
    }
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
}
