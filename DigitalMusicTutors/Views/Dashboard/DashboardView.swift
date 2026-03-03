import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: DashboardViewModel
    @State private var showAddStudent = false
    @State private var showAddTask = false

    init() {
        // Initialised lazily with context in onAppear
        _viewModel = StateObject(wrappedValue: DashboardViewModel(context: PersistenceController.shared.container.viewContext))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let period = hour < 12 ? "morning" : (hour < 17 ? "afternoon" : "evening")
        let name = UserDefaults.standard.string(forKey: "teacherName") ?? "Teacher"
        return "Good \(period), \(name)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                    // Header greeting
                    Text(greeting)
                        .font(.dmtDisplay(28))
                        .foregroundColor(.dmtPrimaryText)
                        .padding(.horizontal, AppTheme.paddingLarge)
                        .padding(.top, AppTheme.paddingMedium)

                    let studioName = UserDefaults.standard.string(forKey: "studioName") ?? "Digital Music Tutors"
                    Text(studioName.uppercased())
                        .dmtLabel()
                        .padding(.horizontal, AppTheme.paddingLarge)
                        .padding(.top, -AppTheme.paddingMedium)

                    // Stat cards 2×2 grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: AppTheme.paddingMedium) {
                        StatCard(title: "Active Students",
                                 value: "\(viewModel.activeStudentCount)",
                                 subtitle: nil,
                                 isAlert: false)

                        StatCard(title: "Lessons This Week",
                                 value: "\(viewModel.lessonsThisWeekCount)",
                                 subtitle: nextLessonSubtitle,
                                 isAlert: false)

                        StatCard(title: "Overdue Tasks",
                                 value: "\(viewModel.overdueTaskCount)",
                                 subtitle: nil,
                                 isAlert: viewModel.overdueTaskCount > 0)

                        StatCard(title: "Resources Posted",
                                 value: "\(viewModel.resourceCount)",
                                 subtitle: nil,
                                 isAlert: false)
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)

                    // Upcoming Lessons
                    SectionHeader("Upcoming Lessons")

                    if viewModel.upcomingLessons.isEmpty {
                        EmptyStateView("No upcoming lessons scheduled.", icon: "calendar")
                            .frame(height: 100)
                    } else {
                        VStack(spacing: AppTheme.paddingSmall) {
                            ForEach(viewModel.upcomingLessons, id: \.id) { lesson in
                                UpcomingLessonRow(lesson: lesson)
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingLarge)
                    }

                    // Activity Feed
                    SectionHeader("Activity")

                    if viewModel.activityFeed.isEmpty {
                        EmptyStateView("No recent activity.", icon: "bolt.slash")
                            .frame(height: 100)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.activityFeed) { event in
                                ActivityRow(event: event)
                            }
                        }
                        .dmtCard()
                        .padding(.horizontal, AppTheme.paddingLarge)
                    }

                    // Quick Actions
                    HStack(spacing: AppTheme.paddingMedium) {
                        QuickActionButton(label: "+ New Student") {
                            showAddStudent = true
                        }
                        QuickActionButton(label: "+ New Task") {
                            showAddTask = true
                        }
                    }
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.bottom, AppTheme.paddingXL)
                }
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
            }
            .sheet(isPresented: $showAddStudent) {
                AddStudentSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear { viewModel.refresh() }
        }
    }

    private var nextLessonSubtitle: String? {
        guard let next = viewModel.nextLesson, let date = next.date else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Next: \(formatter.string(from: date))"
    }
}

// MARK: - Stat Card
private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let isAlert: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.dmtLabel(8))
                .tracking(1.5)
                .foregroundColor(.dmtMutedText)

            Text(value)
                .font(.dmtDisplay(36))
                .foregroundColor(isAlert ? .dmtCrimson : .dmtPrimaryText)

            if let subtitle {
                Text(subtitle)
                    .font(.dmtBody(11))
                    .foregroundColor(.dmtMutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.paddingMedium)
        .dmtGoldTopCard()
    }
}

// MARK: - Upcoming Lesson Row
private struct UpcomingLessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(spacing: AppTheme.paddingMedium) {
            VStack(alignment: .leading, spacing: 2) {
                Text(timeString)
                    .font(.dmtDisplay(24))
                    .foregroundColor(.dmtGold)

                Text(lesson.student?.name?.uppercased() ?? "STUDENT")
                    .font(.dmtLabel(9))
                    .tracking(2)
                    .foregroundColor(.dmtPrimaryText)
            }

            Spacer()

            Text("\(lesson.duration) min")
                .font(.dmtBody(12))
                .foregroundColor(.dmtMutedText)
        }
        .padding(AppTheme.paddingMedium)
        .dmtCard()
    }

    private var timeString: String {
        guard let date = lesson.date else { return "--:--" }
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Activity Row
private struct ActivityRow: View {
    let event: DashboardViewModel.ActivityEvent

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.paddingMedium) {
            Circle()
                .fill(event.isAlert ? Color.dmtCrimson : Color.dmtGold)
                .frame(width: 6, height: 6)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.message)
                    .font(.dmtBody(13))
                    .foregroundColor(.dmtPrimaryText)

                Text(relativeTime)
                    .font(.dmtBody(11))
                    .foregroundColor(.dmtMutedText)
            }
            Spacer()
        }
        .padding(.horizontal, AppTheme.paddingMedium)
        .padding(.vertical, AppTheme.paddingSmall)
        .overlay(
            Divider()
                .background(Color.dmtBorder),
            alignment: .bottom
        )
    }

    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: event.timestamp, relativeTo: Date())
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title.uppercased())
            .font(.dmtLabel(10))
            .tracking(3)
            .foregroundColor(.dmtMutedText)
            .padding(.horizontal, AppTheme.paddingLarge)
    }
}

// MARK: - Quick Action Button
private struct QuickActionButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label.uppercased())
                .font(.dmtLabel(9))
                .tracking(1.5)
                .foregroundColor(.dmtGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.paddingMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(Color.dmtGold, lineWidth: AppTheme.borderWidth)
                )
        }
    }
}

// MARK: - Add Student Sheet (quick entry)
struct AddStudentSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ProgressViewModel

    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var grade = GradeLevel.beginner
    @State private var showWarning = false

    init() {
        _vm = StateObject(wrappedValue: ProgressViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Student Details") {
                    TextField("Full Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Contact Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                Section("Level") {
                    Picker("Grade", selection: $grade) {
                        ForEach(GradeLevel.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }
                }
                if showWarning {
                    Section {
                        Text("Please enter a student name.")
                            .foregroundColor(.dmtCrimson)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.dmtBackground)
            .navigationTitle("New Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.dmtMutedText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.dmtGold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showWarning = true
            return
        }
        vm.addStudent(name: name,
                      age: Int16(age) ?? 0,
                      contactEmail: email,
                      gradeLevel: grade,
                      lessonDay: "",
                      lessonTime: "")
        dismiss()
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ThemeManager.shared)
}
