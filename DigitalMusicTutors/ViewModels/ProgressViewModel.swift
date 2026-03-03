import Foundation
import CoreData

final class ProgressViewModel: ObservableObject {
    @Published var students: [Student] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchStudents()
    }

    func fetchStudents() {
        let request = Student.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        students = (try? context.fetch(request)) ?? []
    }

    func addStudent(name: String,
                    age: Int16,
                    contactEmail: String,
                    gradeLevel: GradeLevel,
                    lessonDay: String,
                    lessonTime: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let student = Student(context: context)
        student.id = UUID()
        student.name = name
        student.age = age
        student.contactEmail = contactEmail
        student.gradeLevel = gradeLevel.rawValue
        student.lessonDay = lessonDay
        student.lessonTime = lessonTime
        student.startDate = Date()
        student.overallProgress = 0

        // Create default skill ratings
        let skillCategories = ["Scales & Arpeggios", "Sight Reading",
                               "Aural Skills", "Theory Knowledge", "Technique & Posture"]
        for category in skillCategories {
            let skill = SkillRating(context: context)
            skill.id = UUID()
            skill.category = category
            skill.rating = 1
            skill.student = student
        }

        saveContext()
        fetchStudents()
    }

    func deleteStudent(_ student: Student) {
        context.delete(student)
        saveContext()
        fetchStudents()
    }

    func updateProgress(_ student: Student, progress: Int16) {
        student.overallProgress = progress
        saveContext()
    }

    func updateGrade(_ student: Student, grade: GradeLevel) {
        student.gradeLevel = grade.rawValue
        saveContext()
    }

    func addPiece(to student: Student, title: String, status: String) {
        let piece = Piece(context: context)
        piece.id = UUID()
        piece.title = title
        piece.status = status
        piece.student = student
        saveContext()
    }

    func deletePiece(_ piece: Piece) {
        context.delete(piece)
        saveContext()
    }

    func updateSkillRating(student: Student, category: String, rating: Int16) {
        let ratings = (student.skillRatings as? Set<SkillRating>) ?? []
        if let existing = ratings.first(where: { $0.category == category }) {
            existing.rating = rating
        } else {
            let skill = SkillRating(context: context)
            skill.id = UUID()
            skill.category = category
            skill.rating = rating
            skill.student = student
        }
        saveContext()
    }

    func addNote(to student: Student, content: String) {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let note = TeacherNote(context: context)
        note.id = UUID()
        note.content = content
        note.timestamp = Date()
        note.student = student
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("ProgressViewModel save error: \(error)")
        }
    }
}
