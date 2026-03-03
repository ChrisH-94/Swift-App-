import SwiftUI

struct StudentProgressProfile: View {
    let student: Student
    @ObservedObject var viewModel: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var progress: Double
    @State private var grade: GradeLevel
    @State private var newPieceTitle = ""
    @State private var newPieceStatus = "learning"
    @State private var newNoteText = ""
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var skillRatings: [String: Int] = [:]

    let skillCategories = ["Scales & Arpeggios", "Sight Reading",
                           "Aural Skills", "Theory Knowledge", "Technique & Posture"]
    let pieceStatuses = ["learning", "polished", "performed"]

    init(student: Student, viewModel: ProgressViewModel) {
        self.student = student
        self.viewModel = viewModel
        _progress = State(initialValue: Double(student.overallProgress))
        _grade = State(initialValue: GradeLevel(rawValue: student.gradeLevel ?? "") ?? .beginner)
    }

    private var sortedNotes: [TeacherNote] {
        let notes = (student.notes as? Set<TeacherNote>) ?? []
        return notes.sorted { ($0.timestamp ?? Date()) > ($1.timestamp ?? Date()) }
    }

    private var sortedPieces: [Piece] {
        let pieces = (student.pieces as? Set<Piece>) ?? []
        return pieces.sorted { ($0.title ?? "") < ($1.title ?? "") }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(student.name ?? "")
                        .font(.dmtDisplay(32))
                        .foregroundColor(.dmtPrimaryText)

                    HStack(spacing: AppTheme.paddingMedium) {
                        GradeBadge(grade: grade)

                        if let startDate = student.startDate {
                            Text("Since \(startDate, style: .date)")
                                .font(.dmtBody(12))
                                .foregroundColor(.dmtMutedText)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)
                .padding(.top, AppTheme.paddingMedium)

                Divider().background(Color.dmtBorder).padding(.horizontal, AppTheme.paddingLarge)

                // Progress slider
                VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                    HStack {
                        Text("Overall Progress".uppercased())
                            .dmtLabel()
                        Spacer()
                        Text("\(Int(progress))%")
                            .font(.dmtDisplay(24))
                            .foregroundColor(.dmtGold)
                    }
                    Slider(value: $progress, in: 0...100, step: 1)
                        .accentColor(.dmtGold)
                        .onChange(of: progress) { newValue in
                            viewModel.updateProgress(student, progress: Int16(newValue))
                        }
                    ProgressBarView(progress: progress / 100.0)
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                // Grade picker
                VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                    Text("Grade / Level".uppercased())
                        .dmtLabel()
                        .padding(.horizontal, AppTheme.paddingLarge)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.paddingSmall) {
                            ForEach(GradeLevel.allCases) { g in
                                Button {
                                    grade = g
                                    viewModel.updateGrade(student, grade: g)
                                } label: {
                                    Text(g.displayName.uppercased())
                                        .font(.dmtLabel(8))
                                        .tracking(1.5)
                                        .foregroundColor(grade == g ? .dmtBackground : .dmtMutedText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(grade == g ? Color.dmtGold : Color.dmtCard)
                                        .cornerRadius(AppTheme.cornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                                .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingLarge)
                    }
                }

                Divider().background(Color.dmtBorder).padding(.horizontal, AppTheme.paddingLarge)

                // Skills assessment
                VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                    Text("Skills Assessment".uppercased())
                        .dmtLabel()

                    ForEach(skillCategories, id: \.self) { category in
                        HStack {
                            Text(category)
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            StarRatingView(
                                category: category,
                                rating: Binding(
                                    get: { skillRatings[category] ?? currentRating(for: category) },
                                    set: { newRating in
                                        skillRatings[category] = newRating
                                        viewModel.updateSkillRating(student: student,
                                                                    category: category,
                                                                    rating: Int16(newRating))
                                    }
                                )
                            )
                        }
                        .padding(AppTheme.paddingMedium)
                        .dmtCard()
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Divider().background(Color.dmtBorder).padding(.horizontal, AppTheme.paddingLarge)

                // Repertoire
                VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                    Text("Repertoire".uppercased())
                        .dmtLabel()

                    ForEach(sortedPieces, id: \.id) { piece in
                        HStack {
                            Text(piece.title ?? "")
                                .font(.dmtBody(14))
                                .foregroundColor(.dmtPrimaryText)
                            Spacer()
                            PieceStatusBadge(status: piece.status ?? "learning")
                        }
                        .padding(AppTheme.paddingMedium)
                        .dmtCard()
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deletePiece(piece)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .tint(.dmtCrimson)
                        }
                    }

                    // Add piece
                    HStack(spacing: AppTheme.paddingSmall) {
                        TextField("Add piece title", text: $newPieceTitle)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                            .padding(AppTheme.paddingMedium)
                            .background(Color.dmtCard)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                            )

                        Menu {
                            ForEach(pieceStatuses, id: \.self) { s in
                                Button(s.capitalized) { newPieceStatus = s }
                            }
                        } label: {
                            Text(newPieceStatus.capitalized)
                                .font(.dmtLabel(9))
                                .foregroundColor(.dmtGold)
                                .padding(AppTheme.paddingMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(Color.dmtGold, lineWidth: AppTheme.borderWidth)
                                )
                        }

                        Button {
                            guard !newPieceTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            viewModel.addPiece(to: student, title: newPieceTitle, status: newPieceStatus)
                            newPieceTitle = ""
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .ultraLight))
                                .foregroundColor(.dmtGold)
                                .padding(AppTheme.paddingMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(Color.dmtGold, lineWidth: AppTheme.borderWidth)
                                )
                        }
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Divider().background(Color.dmtBorder).padding(.horizontal, AppTheme.paddingLarge)

                // Teacher notes
                VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                    Text("Teacher Notes".uppercased())
                        .dmtLabel()

                    ForEach(sortedNotes, id: \.id) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            if let ts = note.timestamp {
                                Text(ts, style: .date)
                                    .font(.dmtLabel(8))
                                    .tracking(1)
                                    .foregroundColor(.dmtMutedText)
                            }
                            Text(note.content ?? "")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                        }
                        .padding(AppTheme.paddingMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dmtCard()
                    }

                    // Add note
                    HStack(spacing: AppTheme.paddingSmall) {
                        TextEditor(text: $newNoteText)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                            .padding(AppTheme.paddingSmall)
                            .background(Color.dmtCard)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                            )

                        Button {
                            viewModel.addNote(to: student, content: newNoteText)
                            newNoteText = ""
                        } label: {
                            Text("Add Note".uppercased())
                                .font(.dmtLabel(9))
                                .tracking(1.5)
                                .foregroundColor(.dmtBackground)
                                .padding(AppTheme.paddingMedium)
                                .background(Color.dmtGold)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.paddingLarge)

                Divider().background(Color.dmtBorder).padding(.horizontal, AppTheme.paddingLarge)

                // Share progress report
                Button {
                    generateAndSharePDF()
                } label: {
                    Text("Share Progress Report".uppercased())
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
        }
        .background(Color.dmtBackground.ignoresSafeArea())
        .navigationTitle(student.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    private func currentRating(for category: String) -> Int {
        let ratings = (student.skillRatings as? Set<SkillRating>) ?? []
        return Int(ratings.first(where: { $0.category == category })?.rating ?? 1)
    }

    private func generateAndSharePDF() {
        pdfURL = PDFGenerator.generate(for: student,
                                       progress: Int(progress),
                                       grade: grade,
                                       skillRatings: skillRatings,
                                       notes: sortedNotes,
                                       pieces: sortedPieces)
        showShareSheet = true
    }
}

// MARK: - Piece Status Badge
private struct PieceStatusBadge: View {
    let status: String
    var color: Color {
        switch status {
        case "polished": return .dmtGold
        case "performed": return .dmtSage
        default: return .dmtMutedText
        }
    }
    var body: some View {
        Text(status.uppercased())
            .font(.dmtLabel(7))
            .tracking(1)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(color, lineWidth: AppTheme.borderWidth)
            )
    }
}

// MARK: - ShareSheet UIKit wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let student = (try? context.fetch(Student.fetchRequest()))?.first
        ?? {
            let s = Student(context: context)
            s.name = "Preview Student"
            return s
        }()
    return NavigationStack {
        StudentProgressProfile(student: student,
                               viewModel: ProgressViewModel(context: context))
    }
    .environment(\.managedObjectContext, context)
}
