import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        let hasRequested = UserDefaults.standard.bool(forKey: "notificationPermissionRequested")
        guard !hasRequested else { return }

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "notificationPermissionRequested")
                    if let error {
                        print("Notification permission error: \(error)")
                    }
                }
            }
    }

    func scheduleLesson(_ lesson: Lesson) {
        guard UserDefaults.standard.bool(forKey: "remindersEnabled") else { return }
        guard let lessonDate = lesson.date,
              let lessonID = lesson.id?.uuidString else { return }

        let reminderMinutes = UserDefaults.standard.integer(forKey: "reminderMinutes")
        let offsetMinutes = reminderMinutes == 0 ? 60 : reminderMinutes
        let fireDate = lessonDate.addingTimeInterval(-Double(offsetMinutes * 60))

        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        let studentName = lesson.student?.name ?? "Student"
        content.title = "Upcoming Lesson — \(studentName)"
        content.body = "Your lesson starts in \(offsetMinutes) minutes. Good luck!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                          from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: lessonID,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Notification schedule error: \(error)")
            }
        }

        // Schedule recurring if needed
        if lesson.recurrence == "weekly" {
            scheduleRecurring(lesson: lesson, fireDate: fireDate,
                              interval: 7 * 24 * 3600, count: 12)
        } else if lesson.recurrence == "fortnightly" {
            scheduleRecurring(lesson: lesson, fireDate: fireDate,
                              interval: 14 * 24 * 3600, count: 6)
        }
    }

    private func scheduleRecurring(lesson: Lesson,
                                   fireDate: Date,
                                   interval: TimeInterval,
                                   count: Int) {
        guard let lessonID = lesson.id?.uuidString else { return }
        let studentName = lesson.student?.name ?? "Student"
        let offsetMinutes = UserDefaults.standard.integer(forKey: "reminderMinutes")
        let minutes = offsetMinutes == 0 ? 60 : offsetMinutes

        for i in 1...count {
            let recurDate = fireDate.addingTimeInterval(Double(i) * interval)
            guard recurDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Upcoming Lesson — \(studentName)"
            content.body = "Your lesson starts in \(minutes) minutes. Good luck!"
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                              from: recurDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(lessonID)_r\(i)",
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    func cancelLesson(_ lesson: Lesson) {
        guard let lessonID = lesson.id?.uuidString else { return }
        var ids = [lessonID]
        for i in 1...12 { ids.append("\(lessonID)_r\(i)") }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
