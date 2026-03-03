import Foundation
import CoreData

enum JSONExporter {
    static func export(context: NSManagedObjectContext) -> URL? {
        var exportData: [String: Any] = [:]

        // Students
        let studentRequest = Student.fetchRequest()
        let students = (try? context.fetch(studentRequest)) ?? []
        exportData["students"] = students.map { s -> [String: Any] in
            var dict: [String: Any] = [:]
            dict["id"] = s.id?.uuidString ?? ""
            dict["name"] = s.name ?? ""
            dict["age"] = s.age
            dict["contactEmail"] = s.contactEmail ?? ""
            dict["gradeLevel"] = s.gradeLevel ?? ""
            dict["overallProgress"] = s.overallProgress
            dict["lessonDay"] = s.lessonDay ?? ""
            dict["lessonTime"] = s.lessonTime ?? ""
            if let startDate = s.startDate {
                dict["startDate"] = ISO8601DateFormatter().string(from: startDate)
            }
            return dict
        }

        // Tasks
        let taskRequest = HomeworkTask.fetchRequest()
        let tasks = (try? context.fetch(taskRequest)) ?? []
        exportData["tasks"] = tasks.map { t -> [String: Any] in
            var dict: [String: Any] = [:]
            dict["id"] = t.id?.uuidString ?? ""
            dict["title"] = t.title ?? ""
            dict["description"] = t.taskDescription ?? ""
            dict["priority"] = t.priority
            dict["status"] = t.status ?? ""
            dict["studentId"] = t.student?.id?.uuidString ?? ""
            if let due = t.dueDate {
                dict["dueDate"] = ISO8601DateFormatter().string(from: due)
            }
            return dict
        }

        // Lessons
        let lessonRequest = Lesson.fetchRequest()
        let lessons = (try? context.fetch(lessonRequest)) ?? []
        exportData["lessons"] = lessons.map { l -> [String: Any] in
            var dict: [String: Any] = [:]
            dict["id"] = l.id?.uuidString ?? ""
            dict["duration"] = l.duration
            dict["recurrence"] = l.recurrence ?? ""
            dict["notes"] = l.lessonNotes ?? ""
            dict["studentId"] = l.student?.id?.uuidString ?? ""
            if let date = l.date {
                dict["date"] = ISO8601DateFormatter().string(from: date)
            }
            return dict
        }

        // Resources
        let resourceRequest = Resource.fetchRequest()
        let resources = (try? context.fetch(resourceRequest)) ?? []
        exportData["resources"] = resources.map { r -> [String: Any] in
            var dict: [String: Any] = [:]
            dict["id"] = r.id?.uuidString ?? ""
            dict["title"] = r.title ?? ""
            dict["url"] = r.url ?? ""
            dict["category"] = r.category ?? ""
            dict["description"] = r.resourceDescription ?? ""
            dict["assignedTo"] = r.assignedTo ?? "all"
            return dict
        }

        // Notes
        let noteRequest = TeacherNote.fetchRequest()
        let notes = (try? context.fetch(noteRequest)) ?? []
        exportData["notes"] = notes.map { n -> [String: Any] in
            var dict: [String: Any] = [:]
            dict["id"] = n.id?.uuidString ?? ""
            dict["content"] = n.content ?? ""
            dict["studentId"] = n.student?.id?.uuidString ?? ""
            if let ts = n.timestamp {
                dict["timestamp"] = ISO8601DateFormatter().string(from: ts)
            }
            return dict
        }

        exportData["exportDate"] = ISO8601DateFormatter().string(from: Date())

        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData,
                                                          options: .prettyPrinted) else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DigitalMusicTutors_Export.json")
        try? jsonData.write(to: url)
        return url
    }
}
