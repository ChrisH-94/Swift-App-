import Foundation
import PDFKit
import UIKit

// MARK: - PDF Generator
enum PDFGenerator {
    static func generate(for student: Student,
                         progress: Int,
                         grade: GradeLevel,
                         skillRatings: [String: Int],
                         notes: [TeacherNote],
                         pieces: [Piece]) -> URL? {
        let pdfData = NSMutableData()
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPage()

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            return nil
        }

        // Background
        context.setFillColor(UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1).cgColor)
        context.fill(pageRect)

        var yPos: CGFloat = 60

        // Logo / Studio name
        let studioName = UserDefaults.standard.string(forKey: "studioName") ?? "Digital Music Tutors"
        drawText(studioName.uppercased(),
                 at: CGPoint(x: 40, y: yPos),
                 font: UIFont(name: "Georgia", size: 10) ?? .systemFont(ofSize: 10),
                 color: UIColor(red: 0.79, green: 0.66, blue: 0.30, alpha: 1),
                 tracking: 3)
        yPos += 30

        // Divider
        context.setStrokeColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 40, y: yPos))
        context.addLine(to: CGPoint(x: 555, y: yPos))
        context.strokePath()
        yPos += 20

        // Student name
        drawText(student.name ?? "",
                 at: CGPoint(x: 40, y: yPos),
                 font: UIFont(name: "Georgia", size: 28) ?? .systemFont(ofSize: 28),
                 color: UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1))
        yPos += 40

        // Grade + Date
        let dateStr = "Report Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none))"
        drawText("\(grade.displayName.uppercased())  ·  \(dateStr.uppercased())",
                 at: CGPoint(x: 40, y: yPos),
                 font: UIFont.systemFont(ofSize: 8, weight: .medium),
                 color: UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1),
                 tracking: 2)
        yPos += 30

        // Progress
        drawText("OVERALL PROGRESS: \(progress)%",
                 at: CGPoint(x: 40, y: yPos),
                 font: UIFont.systemFont(ofSize: 9, weight: .medium),
                 color: UIColor(red: 0.79, green: 0.66, blue: 0.30, alpha: 1),
                 tracking: 2)
        yPos += 10

        // Progress bar
        let barWidth: CGFloat = 515
        context.setFillColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor)
        context.fill(CGRect(x: 40, y: yPos, width: barWidth, height: 4))
        context.setFillColor(UIColor(red: 0.79, green: 0.66, blue: 0.30, alpha: 1).cgColor)
        context.fill(CGRect(x: 40, y: yPos, width: barWidth * CGFloat(progress) / 100.0, height: 4))
        yPos += 24

        // Skills
        drawSectionHeader("Skills Assessment", at: &yPos, context: context, pageRect: pageRect)
        let skillCategories = ["Scales & Arpeggios", "Sight Reading",
                               "Aural Skills", "Theory Knowledge", "Technique & Posture"]
        for category in skillCategories {
            let rating = skillRatings[category] ?? 1
            let stars = String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
            drawText("\(category): \(stars)",
                     at: CGPoint(x: 40, y: yPos),
                     font: UIFont.systemFont(ofSize: 11),
                     color: UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1))
            yPos += 18
        }
        yPos += 10

        // Repertoire
        drawSectionHeader("Repertoire", at: &yPos, context: context, pageRect: pageRect)
        for piece in pieces {
            let statusSymbol = piece.status == "performed" ? "✓" : (piece.status == "polished" ? "◉" : "○")
            drawText("\(statusSymbol)  \(piece.title ?? "")  [\((piece.status ?? "learning").capitalized)]",
                     at: CGPoint(x: 40, y: yPos),
                     font: UIFont.systemFont(ofSize: 11),
                     color: UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1))
            yPos += 18
        }
        yPos += 10

        // Latest note
        if let latestNote = notes.first {
            drawSectionHeader("Latest Teacher Note", at: &yPos, context: context, pageRect: pageRect)
            let noteText = latestNote.content ?? ""
            drawText(noteText,
                     at: CGPoint(x: 40, y: yPos),
                     font: UIFont(name: "Georgia-Italic", size: 12) ?? .italicSystemFont(ofSize: 12),
                     color: UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1),
                     maxWidth: 515)
        }

        // Footer
        let contactEmail = UserDefaults.standard.string(forKey: "contactEmail") ?? ""
        if !contactEmail.isEmpty {
            drawText("Contact: \(contactEmail)",
                     at: CGPoint(x: 40, y: 800),
                     font: UIFont.systemFont(ofSize: 8),
                     color: UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1))
        }

        UIGraphicsEndPDFContext()

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(student.name ?? "Student")_Progress_Report.pdf")
        pdfData.write(to: url, atomically: true)
        return url
    }

    private static func drawSectionHeader(_ title: String,
                                          at yPos: inout CGFloat,
                                          context: CGContext,
                                          pageRect: CGRect) {
        yPos += 8
        context.setStrokeColor(UIColor(red: 0.79, green: 0.66, blue: 0.30, alpha: 0.4).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 40, y: yPos))
        context.addLine(to: CGPoint(x: 555, y: yPos))
        context.strokePath()
        yPos += 8

        drawText(title.uppercased(),
                 at: CGPoint(x: 40, y: yPos),
                 font: UIFont.systemFont(ofSize: 8, weight: .medium),
                 color: UIColor(red: 0.79, green: 0.66, blue: 0.30, alpha: 1),
                 tracking: 2)
        yPos += 20
    }

    private static func drawText(_ text: String,
                                  at point: CGPoint,
                                  font: UIFont,
                                  color: UIColor,
                                  tracking: CGFloat = 0,
                                  maxWidth: CGFloat = 0) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        if tracking > 0 {
            attributes[.kern] = tracking
        }

        let attrString = NSAttributedString(string: text, attributes: attributes)

        if maxWidth > 0 {
            // Word-wrap for notes
            let textRect = CGRect(x: point.x, y: point.y, width: maxWidth, height: 200)
            attrString.draw(in: textRect)
        } else {
            attrString.draw(at: point)
        }
    }
}
