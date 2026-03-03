import Foundation
import CoreData
import Combine

final class HomeworkViewModel: ObservableObject {
    @Published var tasks: [HomeworkTask] = []
    @Published var filterStatus: TaskFilter = .all

    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case overdue = "Overdue"
        case complete = "Complete"
    }

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
        updateOverdueStatuses()
    }

    var filteredTasks: [HomeworkTask] {
        switch filterStatus {
        case .all:
            return tasks
        case .pending:
            return tasks.filter { $0.status == "pending" }
        case .overdue:
            return tasks.filter { $0.status == "overdue" }
        case .complete:
            return tasks.filter { $0.status == "complete" }
        }
    }

    func fetchTasks() {
        let request = HomeworkTask.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "dueDate", ascending: true)
        ]
        tasks = (try? context.fetch(request)) ?? []
    }

    func updateOverdueStatuses() {
        let now = Date()
        for task in tasks where task.status == "pending" {
            if let dueDate = task.dueDate, dueDate < now {
                task.status = "overdue"
            }
        }
        saveContext()
    }

    func addTask(title: String,
                 description: String,
                 dueDate: Date,
                 priority: Int16,
                 student: Student) {
        let task = HomeworkTask(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = description
        task.dueDate = dueDate
        task.priority = priority
        task.status = dueDate < Date() ? "overdue" : "pending"
        task.student = student
        saveContext()
        fetchTasks()
    }

    func markComplete(_ task: HomeworkTask) {
        task.status = "complete"
        saveContext()
        fetchTasks()
    }

    func deleteTask(_ task: HomeworkTask) {
        context.delete(task)
        saveContext()
        fetchTasks()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("HomeworkViewModel save error: \(error)")
        }
    }
}
