import SwiftUI

struct GradeBadge: View {
    let grade: GradeLevel

    var body: some View {
        Text(grade.displayName.uppercased())
            .font(.dmtLabel(8))
            .tracking(1.5)
            .foregroundColor(grade.isAdvanced ? .dmtGold : .dmtMutedText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(grade.isAdvanced ? Color.dmtGold : Color.dmtBorder,
                            lineWidth: AppTheme.borderWidth)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        GradeBadge(grade: .beginner)
        GradeBadge(grade: .grade3)
        GradeBadge(grade: .grade5)
        GradeBadge(grade: .diploma)
    }
    .padding()
    .background(Color.dmtBackground)
}
