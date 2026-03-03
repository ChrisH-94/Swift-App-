import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CalendarViewModel
    @State private var showAddLesson = false
    @State private var showDaySheet = false

    init() {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.paddingLarge) {
                    CalendarGrid(viewModel: viewModel, showDaySheet: $showDaySheet)
                        .padding(.horizontal, AppTheme.paddingLarge)

                    SectionHeader("Upcoming Lessons")

                    if viewModel.upcomingLessons.isEmpty {
                        EmptyStateView("No upcoming lessons.", icon: "calendar.badge.clock")
                            .frame(height: 100)
                    } else {
                        VStack(spacing: AppTheme.paddingSmall) {
                            ForEach(viewModel.upcomingLessons, id: \.id) { lesson in
                                UpcomingLessonCard(lesson: lesson) {
                                    viewModel.deleteLesson(lesson)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingLarge)
                    }
                }
                .padding(.bottom, AppTheme.paddingXL)
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("Calendar")
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
                        showAddLesson = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
            }
            .sheet(isPresented: $showAddLesson, onDismiss: { viewModel.fetchAllLessons() }) {
                AddLessonSheet(selectedDate: viewModel.selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showDaySheet) {
                DayLessonsSheet(viewModel: viewModel)
            }
            .onAppear { viewModel.fetchAllLessons() }
        }
    }
}

// MARK: - Upcoming Lesson Card
private struct UpcomingLessonCard: View {
    let lesson: Lesson
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.paddingMedium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.student?.name?.uppercased() ?? "STUDENT")
                    .font(.dmtLabel(9))
                    .tracking(2)
                    .foregroundColor(.dmtPrimaryText)

                Text(dateTimeString)
                    .font(.dmtBody(12))
                    .foregroundColor(.dmtMutedText)

                Text("\(lesson.duration) min · \((lesson.recurrence ?? "one-off").capitalized)")
                    .font(.dmtBody(11))
                    .foregroundColor(.dmtMutedText)
            }
            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(.dmtCrimson)
            }
        }
        .padding(AppTheme.paddingMedium)
        .dmtCard()
    }

    private var dateTimeString: String {
        guard let date = lesson.date else { return "" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Day Lessons Sheet
private struct DayLessonsSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.lessonsForSelectedDate.isEmpty {
                    EmptyStateView("No lessons on this day.", icon: "calendar")
                } else {
                    List(viewModel.lessonsForSelectedDate, id: \.id) { lesson in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.student?.name ?? "")
                                .font(.dmtBody(14))
                                .foregroundColor(.dmtPrimaryText)
                            if let date = lesson.date {
                                Text(date, style: .time)
                                    .font(.dmtBody(12))
                                    .foregroundColor(.dmtGold)
                            }
                            Text("\(lesson.duration) min")
                                .font(.dmtBody(11))
                                .foregroundColor(.dmtMutedText)
                        }
                        .listRowBackground(Color.dmtCard)
                        .listRowSeparatorTint(Color.dmtBorder)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.dmtBackground)
                }
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.dmtGold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    CalendarView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
