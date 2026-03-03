import SwiftUI

struct StarRatingView: View {
    let category: String
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .ultraLight))
                        .foregroundColor(star <= rating ? .dmtGold : .dmtBorder)
                }
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(3) { rating in
        StarRatingView(category: "Scales", rating: rating)
    }
    .padding()
    .background(Color.dmtBackground)
}

// Helper for previewing @Binding
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
