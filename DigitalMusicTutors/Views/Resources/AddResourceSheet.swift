import SwiftUI
import LinkPresentation

struct AddResourceSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var urlString = ""
    @State private var title = ""
    @State private var description = ""
    @State private var category = "YouTube Videos"
    @State private var assignedTo = "all"
    @State private var isFetchingMetadata = false
    @State private var thumbnailData: Data?
    @State private var showWarning = false
    @State private var warningMessage = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Student.name, ascending: true)],
        animation: .default
    ) private var students: FetchedResults<Student>

    let categories = ["YouTube Videos", "Theory & Worksheets", "Moodle",
                      "Backing Tracks", "Recommended Reading", "Student Spotlight"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                    FormSection(label: "URL") {
                        HStack {
                            TextField("https://", text: $urlString)
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                                .accentColor(.dmtGold)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()

                            if isFetchingMetadata {
                                ProgressView()
                                    .tint(.dmtGold)
                            } else {
                                Button("Fetch") {
                                    fetchMetadata()
                                }
                                .font(.dmtLabel(9))
                                .tracking(1)
                                .foregroundColor(.dmtGold)
                            }
                        }
                    }

                    FormSection(label: "Title") {
                        TextField("Page title (auto-filled or enter manually)", text: $title)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                    }

                    FormSection(label: "Category") {
                        VStack(spacing: AppTheme.paddingSmall) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    category = cat
                                } label: {
                                    HStack {
                                        Text(cat)
                                            .font(.dmtBody(13))
                                            .foregroundColor(.dmtPrimaryText)
                                        Spacer()
                                        if category == cat {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.dmtGold)
                                                .font(.system(size: 12, weight: .ultraLight))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    FormSection(label: "Description (optional)") {
                        TextEditor(text: $description)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                    }

                    FormSection(label: "Assign To") {
                        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                            Button {
                                assignedTo = "all"
                            } label: {
                                HStack {
                                    Text("All Students")
                                        .font(.dmtBody(13))
                                        .foregroundColor(.dmtPrimaryText)
                                    Spacer()
                                    if assignedTo == "all" {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.dmtGold)
                                            .font(.system(size: 12, weight: .ultraLight))
                                    }
                                }
                            }

                            ForEach(students) { student in
                                Button {
                                    assignedTo = student.id?.uuidString ?? "all"
                                } label: {
                                    HStack {
                                        Text(student.name ?? "")
                                            .font(.dmtBody(13))
                                            .foregroundColor(.dmtPrimaryText)
                                        Spacer()
                                        if assignedTo == student.id?.uuidString {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.dmtGold)
                                                .font(.system(size: 12, weight: .ultraLight))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if showWarning {
                        Text(warningMessage)
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtCrimson)
                            .padding(.horizontal, AppTheme.paddingLarge)
                    }

                    Button(action: save) {
                        Text("Save Resource".uppercased())
                            .font(.dmtLabel(10))
                            .tracking(2)
                            .foregroundColor(.dmtBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.paddingMedium)
                            .background(Color.dmtGold)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.bottom, AppTheme.paddingXL)
                }
                .padding(.top, AppTheme.paddingLarge)
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("New Resource")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.dmtMutedText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func fetchMetadata() {
        guard let url = URL(string: urlString) else { return }
        isFetchingMetadata = true
        LinkMetadataFetcher.fetch(url: url) { fetchedTitle, imageData in
            DispatchQueue.main.async {
                isFetchingMetadata = false
                if let fetchedTitle, title.isEmpty {
                    title = fetchedTitle
                }
                thumbnailData = imageData
            }
        }
    }

    private func save() {
        showWarning = false
        guard !urlString.trimmingCharacters(in: .whitespaces).isEmpty else {
            warningMessage = "Please enter a URL."
            showWarning = true
            return
        }
        let vm = ResourceViewModel(context: viewContext)
        vm.addResource(title: title,
                       url: urlString,
                       category: category,
                       description: description,
                       assignedTo: assignedTo,
                       thumbnailData: thumbnailData)
        dismiss()
    }
}

#Preview {
    AddResourceSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
