import SwiftUI
import PhotosUI

struct AppIconUploaderView: View {
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?

    let iconSizes: [(String, CGFloat)] = [
        ("20pt", 20), ("29pt", 29), ("40pt", 40), ("60pt", 60),
        ("76pt", 76), ("83.5pt", 83.5), ("1024pt", 120) // Displayed at 120pt for preview
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                // Picker
                PhotosPicker(selection: $photosPickerItem,
                             matching: .images,
                             photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 16, weight: .ultraLight))
                        Text("Select Image (PNG, 1024×1024px min.)".uppercased())
                            .font(.dmtLabel(9))
                            .tracking(1.5)
                    }
                    .foregroundColor(.dmtGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.paddingMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(Color.dmtGold, lineWidth: AppTheme.borderWidth)
                    )
                }
                .onChange(of: photosPickerItem) { item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                            ImagePersistence.saveAppIcon(data: data)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                if let image = selectedImage {
                    // Icon previews
                    Text("Icon Previews".uppercased())
                        .dmtLabel()
                        .padding(.horizontal, AppTheme.paddingLarge)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),
                                        GridItem(.flexible()), GridItem(.flexible())],
                              spacing: AppTheme.paddingMedium) {
                        ForEach(iconSizes, id: \.0) { size in
                            VStack(spacing: 6) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: min(size.1, 80), height: min(size.1, 80))
                                    .clipShape(RoundedRectangle(cornerRadius: min(size.1, 80) * 0.22))
                                    .clipped()

                                Text(size.0)
                                    .font(.dmtBody(9))
                                    .foregroundColor(.dmtMutedText)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)

                    // Instructions
                    VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                        Text("How to Set Your App Icon".uppercased())
                            .dmtLabel()

                        Text("Export this image and drag it into your Xcode Assets.xcassets > AppIcon to set your App Store icon.")
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtMutedText)
                    }
                    .padding(AppTheme.paddingMedium)
                    .dmtCard()
                    .padding(.horizontal, AppTheme.paddingLarge)
                } else {
                    // Load persisted icon if available
                    if let savedData = ImagePersistence.loadAppIcon(),
                       let savedImage = UIImage(data: savedData) {
                        Text("Previously uploaded icon:")
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtMutedText)
                            .padding(.horizontal, AppTheme.paddingLarge)

                        Image(uiImage: savedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .padding(.horizontal, AppTheme.paddingLarge)
                    }
                }

                Spacer(minLength: AppTheme.paddingXL)
            }
            .padding(.top, AppTheme.paddingLarge)
        }
        .background(Color.dmtBackground.ignoresSafeArea())
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppIconUploaderView()
    }
    .preferredColorScheme(.dark)
}
