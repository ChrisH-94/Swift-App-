import Foundation
import CoreData

final class ResourceViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var selectedCategory: String = "All"

    let categories = ["All", "YouTube Videos", "Theory & Worksheets",
                      "Moodle", "Backing Tracks", "Recommended Reading", "Student Spotlight"]

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchResources()
        seedDefaultResourcesIfNeeded()
    }

    var filteredResources: [Resource] {
        guard selectedCategory != "All" else { return resources }
        return resources.filter { $0.category == selectedCategory }
    }

    func fetchResources() {
        let request = Resource.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        resources = (try? context.fetch(request)) ?? []
    }

    func addResource(title: String,
                     url: String,
                     category: String,
                     description: String,
                     assignedTo: String,
                     thumbnailData: Data? = nil) {
        guard !url.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let resource = Resource(context: context)
        resource.id = UUID()
        resource.title = title.isEmpty ? url : title
        resource.url = url
        resource.category = category
        resource.resourceDescription = description
        resource.assignedTo = assignedTo
        resource.thumbnailData = thumbnailData
        saveContext()
        fetchResources()
    }

    func deleteResource(_ resource: Resource) {
        context.delete(resource)
        saveContext()
        fetchResources()
    }

    func updateThumbnail(for resource: Resource, data: Data) {
        resource.thumbnailData = data
        saveContext()
    }

    private func seedDefaultResourcesIfNeeded() {
        let key = "defaultResourcesSeeded"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        let moodleURL = UserDefaults.standard.string(forKey: "moodleURL") ?? "https://moodle.example.com"

        addResource(title: "Digital Music Tutors – Moodle",
                    url: moodleURL,
                    category: "Moodle",
                    description: "Course materials and resources on Moodle",
                    assignedTo: "all")

        addResource(title: "Piano Lessons – YouTube Playlist",
                    url: "https://www.youtube.com/@digitalmusictutors",
                    category: "YouTube Videos",
                    description: "Video lessons and tutorials — update URL in Settings",
                    assignedTo: "all")

        UserDefaults.standard.set(true, forKey: key)
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("ResourceViewModel save error: \(error)")
        }
    }
}
