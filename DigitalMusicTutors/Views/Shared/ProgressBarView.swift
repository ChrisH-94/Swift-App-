import SwiftUI

struct ProgressBarView: View {
    let progress: Double // 0.0 to 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.dmtBorder)
                    .frame(height: AppTheme.progressBarHeight)

                Rectangle()
                    .fill(AppTheme.goldGradient)
                    .frame(width: geo.size.width * max(0, min(1, progress)),
                           height: AppTheme.progressBarHeight)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: AppTheme.progressBarHeight)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.3)
        ProgressBarView(progress: 0.65)
        ProgressBarView(progress: 1.0)
    }
    .padding()
    .background(Color.dmtBackground)
}
