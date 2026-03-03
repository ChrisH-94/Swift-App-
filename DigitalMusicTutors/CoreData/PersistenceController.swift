import CoreData

// MARK: - CoreData Stack
final class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Create sample data for previews
        let student = Student(context: viewContext)
        student.id = UUID()
        student.name = "Alice Johnson"
        student.gradeLevel = GradeLevel.grade3.rawValue
        student.overallProgress = 65
        student.startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        student.age = 12

        let task = HomeworkTask(context: viewContext)
        task.id = UUID()
        task.title = "Practise Scales C Major"
        task.taskDescription = "Hands separately first, then together"
        task.dueDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        task.priority = 1
        task.status = "pending"
        task.student = student

        let lesson = Lesson(context: viewContext)
        lesson.id = UUID()
        lesson.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        lesson.duration = 60
        lesson.recurrence = "weekly"
        lesson.student = student

        try? viewContext.save()
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DigitalMusicTutors")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this gracefully
                fatalError("CoreData store failed to load: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("CoreData save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
