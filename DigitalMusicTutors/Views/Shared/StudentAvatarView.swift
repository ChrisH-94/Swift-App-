import SwiftUI

struct StudentAvatarView: View {
    let name: String
    let size: CGFloat

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.compactMap { $0.first.map { String($0) } }
        return letters.prefix(2).joined().uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.dmtCard)
                .overlay(Circle().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))

            Text(initials)
                .font(.dmtLabel(size * 0.35))
                .tracking(1)
                .foregroundColor(.dmtGold)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        StudentAvatarView(name: "Alice Johnson", size: 44)
        StudentAvatarView(name: "Bob", size: 44)
        StudentAvatarView(name: "C D", size: 32)
    }
    .padding()
    .background(Color.dmtBackground)
}
