import Foundation
import CoreData
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var activeStudentCount: Int = 0
    @Published var lessonsThisWeekCount: Int = 0
    @Published var nextLesson: Lesson?
    @Published var overdueTaskCount: Int = 0
    @Published var resourceCount: Int = 0
    @Published var upcomingLessons: [Lesson] = []
    @Published var activityFeed: [ActivityEvent] = []

    private let context: NSManagedObjectContext

    struct ActivityEvent: Identifiable {
        let id = UUID()
        let timestamp: Date
        let message: String
        let isAlert: Bool
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        fetchStudentCount()
        fetchLessonsThisWeek()
        fetchOverdueTasks()
        fetchResourceCount()
        fetchUpcomingLessons()
        buildActivityFeed()
    }

    private func fetchStudentCount() {
        let request = Student.fetchRequest()
        activeStudentCount = (try? context.count(for: request)) ?? 0
    }

    private func fetchLessonsThisWeek() {
        let now = Date()
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
              let weekEnd = calendar.dateInterval(of: .weekOfYear, for: now)?.end else { return }

        let request = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        weekStart as NSDate, weekEnd as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let lessons = (try? context.fetch(request)) ?? []
        lessonsThisWeekCount = lessons.count
        nextLesson = lessons.first(where: { ($0.date ?? Date()) > now })
    }

    private func fetchOverdueTasks() {
        let request = HomeworkTask.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", "overdue")
        overdueTaskCount = (try? context.count(for: request)) ?? 0
    }

    private func fetchResourceCount() {
        let request = Resource.fetchRequest()
        resourceCount = (try? context.count(for: request)) ?? 0
    }

    func fetchUpcomingLessons() {
        let now = Date()
        let request = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", now as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.fetchLimit = 4
        upcomingLessons = (try? context.fetch(request)) ?? []
    }

    private func buildActivityFeed() {
        var events: [ActivityEvent] = []

        // Fetch recent completed tasks
        let taskRequest = HomeworkTask.fetchRequest()
        taskRequest.predicate = NSPredicate(format: "status == %@", "complete")
        taskRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: false)]
        taskRequest.fetchLimit = 5
        let tasks = (try? context.fetch(taskRequest)) ?? []
        for task in tasks {
            if let date = task.dueDate {
                let name = task.student?.name ?? "Student"
                events.append(ActivityEvent(timestamp: date,
                                            message: "\(name) completed "\(task.title ?? "Task")"",
                                            isAlert: false))
            }
        }

        // Fetch overdue tasks
        let overdueRequest = HomeworkTask.fetchRequest()
        overdueRequest.predicate = NSPredicate(format: "status == %@", "overdue")
        let overdue = (try? context.fetch(overdueRequest)) ?? []
        for task in overdue {
            if let date = task.dueDate {
                let name = task.student?.name ?? "Student"
                events.append(ActivityEvent(timestamp: date,
                                            message: "\(name)'s task "\(task.title ?? "Task")" is overdue",
                                            isAlert: true))
            }
        }

        // Sort by timestamp descending
        activityFeed = events.sorted { $0.timestamp > $1.timestamp }
    }
}
