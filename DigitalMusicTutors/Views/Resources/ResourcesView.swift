import SwiftUI
import SafariServices

struct ResourcesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ResourceViewModel
    @State private var showAddResource = false
    @State private var selectedURL: URL?
    @State private var showSafari = false

    init() {
        _viewModel = StateObject(wrappedValue: ResourceViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.paddingSmall) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            Button {
                                viewModel.selectedCategory = cat
                            } label: {
                                Text(cat.uppercased())
                                    .font(.dmtLabel(8))
                                    .tracking(1.5)
                                    .foregroundColor(viewModel.selectedCategory == cat ? .dmtBackground : .dmtMutedText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedCategory == cat ? Color.dmtGold : Color.dmtCard)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.vertical, AppTheme.paddingMedium)
                }

                Divider().background(Color.dmtBorder)

                if viewModel.filteredResources.isEmpty {
                    EmptyStateView("No resources in this category yet.", icon: "books.vertical")
                } else {
                    List {
                        ForEach(viewModel.filteredResources, id: \.id) { resource in
                            ResourceCard(resource: resource) {
                                if let urlStr = resource.url, let url = URL(string: urlStr) {
                                    selectedURL = url
                                    showSafari = true
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteResource(resource)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.dmtCrimson)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.dmtBackground)
                }
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAddResource = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
            }
            .sheet(isPresented: $showAddResource, onDismiss: { viewModel.fetchResources() }) {
                AddResourceSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showSafari) {
                if let url = selectedURL {
                    SafariView(url: url)
                }
            }
            .onAppear { viewModel.fetchResources() }
        }
    }
}

// MARK: - Resource Card
private struct ResourceCard: View {
    let resource: Resource
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text((resource.title ?? "Untitled").uppercased())
                        .font(.dmtLabel(9))
                        .tracking(2)
                        .foregroundColor(.dmtPrimaryText)
                        .lineLimit(2)

                    if let cat = resource.category {
                        Text(cat)
                            .font(.dmtLabel(8))
                            .tracking(1)
                            .foregroundColor(.dmtGold)
                    }
                }

                Spacer()

                // Thumbnail
                if let data = resource.thumbnailData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 44)
                        .clipped()
                        .cornerRadius(AppTheme.cornerRadius)
                }
            }

            if let desc = resource.resourceDescription, !desc.isEmpty {
                Text(desc)
                    .font(.dmtBody(12))
                    .foregroundColor(.dmtMutedText)
                    .lineLimit(2)
            }

            HStack {
                if let urlStr = resource.url {
                    Text(urlStr)
                        .font(.dmtBody(10))
                        .foregroundColor(.dmtMutedText)
                        .lineLimit(1)
                }
                Spacer()
                Button(action: onOpen) {
                    Text("Open".uppercased())
                        .font(.dmtLabel(8))
                        .tracking(1.5)
                        .foregroundColor(.dmtGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(Color.dmtGold, lineWidth: AppTheme.borderWidth)
                        )
                }
            }
        }
        .padding(AppTheme.paddingMedium)
        .dmtCard()
        .padding(.vertical, 4)
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(Color.dmtSurface)
        vc.preferredControlTintColor = UIColor(Color.dmtGold)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    ResourcesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
