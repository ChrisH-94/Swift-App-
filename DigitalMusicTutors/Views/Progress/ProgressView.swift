import SwiftUI

struct StudentProgressListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProgressViewModel
    @State private var showAddStudent = false

    init() {
        _viewModel = StateObject(wrappedValue: ProgressViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.students.isEmpty {
                    EmptyStateView("No students yet. Add one to get started.", icon: "person.badge.plus")
                } else {
                    List {
                        ForEach(viewModel.students, id: \.id) { student in
                            NavigationLink(destination: StudentProgressProfile(student: student, viewModel: viewModel)) {
                                StudentRow(student: student)
                            }
                            .listRowBackground(Color.dmtCard)
                            .listRowSeparatorTint(Color.dmtBorder)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { viewModel.deleteStudent(viewModel.students[$0]) }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.dmtBackground)
                }
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAddStudent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
            }
            .sheet(isPresented: $showAddStudent, onDismiss: { viewModel.fetchStudents() }) {
                AddStudentSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear { viewModel.fetchStudents() }
        }
    }
}

// MARK: - Student Row
private struct StudentRow: View {
    let student: Student

    private var gradeLevel: GradeLevel {
        GradeLevel(rawValue: student.gradeLevel ?? "") ?? .beginner
    }

    var body: some View {
        HStack(spacing: AppTheme.paddingMedium) {
            StudentAvatarView(name: student.name ?? "?", size: AppTheme.avatarSize)

            VStack(alignment: .leading, spacing: 6) {
                Text((student.name ?? "").uppercased())
                    .font(.dmtLabel(10))
                    .tracking(2)
                    .foregroundColor(.dmtPrimaryText)

                ProgressBarView(progress: Double(student.overallProgress) / 100.0)

                HStack(spacing: AppTheme.paddingSmall) {
                    Text("\(student.overallProgress)%")
                        .font(.dmtBody(11))
                        .foregroundColor(.dmtMutedText)
                    GradeBadge(grade: gradeLevel)
                }
            }
        }
        .padding(.vertical, AppTheme.paddingSmall)
    }
}

#Preview {
    StudentProgressListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
