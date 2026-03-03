import SwiftUI

struct EmptyStateView: View {
    let message: String
    let iconName: String

    init(_ message: String, icon: String = "tray") {
        self.message = message
        self.iconName = icon
    }

    var body: some View {
        VStack(spacing: AppTheme.paddingMedium) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundColor(.dmtMutedText)

            Text(message)
                .font(.custom("Georgia-Italic", size: 16))
                .foregroundColor(.dmtMutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.paddingXL)
    }
}

#Preview {
    EmptyStateView("No tasks assigned yet.", icon: "checklist")
        .background(Color.dmtBackground)
}
