import Foundation
import CoreData

final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var displayedMonth: Date = Date()
    @Published var lessons: [Lesson] = []
    @Published var lessonsForSelectedDate: [Lesson] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAllLessons()
    }

    var daysInDisplayedMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return 1
        }
        // Returns 1 (Sun) to 7 (Sat), convert to 0-based Mon-start
        let rawWeekday = calendar.component(.weekday, from: firstDay)
        return (rawWeekday + 5) % 7 // Monday = 0
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    func advanceMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        fetchLessonsForDate(date)
    }

    func fetchAllLessons() {
        let request = Lesson.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        lessons = (try? context.fetch(request)) ?? []
        fetchLessonsForDate(selectedDate)
    }

    func fetchLessonsForDate(_ date: Date) {
        let calendar = Calendar.current
        lessonsForSelectedDate = lessons.filter {
            guard let lessonDate = $0.date else { return false }
            return calendar.isDate(lessonDate, inSameDayAs: date)
        }
    }

    func lessonsOnDate(_ date: Date) -> [Lesson] {
        let calendar = Calendar.current
        return lessons.filter {
            guard let lessonDate = $0.date else { return false }
            return calendar.isDate(lessonDate, inSameDayAs: date)
        }
    }

    func addLesson(student: Student,
                   date: Date,
                   duration: Int16,
                   recurrence: String,
                   notes: String) {
        let lesson = Lesson(context: context)
        lesson.id = UUID()
        lesson.date = date
        lesson.duration = duration
        lesson.recurrence = recurrence
        lesson.lessonNotes = notes
        lesson.student = student
        saveContext()
        fetchAllLessons()

        // Schedule notification
        NotificationManager.shared.scheduleLesson(lesson)
    }

    func deleteLesson(_ lesson: Lesson) {
        NotificationManager.shared.cancelLesson(lesson)
        context.delete(lesson)
        saveContext()
        fetchAllLessons()
    }

    var upcomingLessons: [Lesson] {
        let now = Date()
        return lessons.filter { ($0.date ?? Date()) >= now }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("CalendarViewModel save error: \(error)")
        }
    }
}
