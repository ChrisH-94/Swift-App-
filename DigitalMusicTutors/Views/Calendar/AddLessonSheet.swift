import SwiftUI

struct AddLessonSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var selectedDate: Date

    @State private var selectedStudent: Student?
    @State private var date: Date
    @State private var duration: Int16 = 60
    @State private var recurrence: String = "one-off"
    @State private var notes = ""
    @State private var showWarning = false
    @State private var warningMessage = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Student.name, ascending: true)],
        animation: .default
    ) private var students: FetchedResults<Student>

    let durations: [Int16] = [15, 30, 45, 60]
    let recurrences = ["one-off", "weekly", "fortnightly"]

    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _date = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                    // Student picker
                    FormSection(label: "Student") {
                        if students.isEmpty {
                            Text("No students yet.")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtMutedText)
                        } else {
                            VStack(spacing: AppTheme.paddingSmall) {
                                ForEach(students) { student in
                                    Button {
                                        selectedStudent = student
                                    } label: {
                                        HStack {
                                            Text(student.name ?? "")
                                                .font(.dmtBody(14))
                                                .foregroundColor(.dmtPrimaryText)
                                            Spacer()
                                            if selectedStudent == student {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.dmtGold)
                                                    .font(.system(size: 12, weight: .ultraLight))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    FormSection(label: "Date & Time") {
                        DatePicker("", selection: $date)
                            .datePickerStyle(.compact)
                            .accentColor(.dmtGold)
                            .colorScheme(.dark)
                    }

                    FormSection(label: "Duration") {
                        HStack(spacing: 0) {
                            ForEach(durations, id: \.self) { d in
                                Button {
                                    duration = d
                                } label: {
                                    Text("\(d) min")
                                        .font(.dmtLabel(9))
                                        .tracking(1)
                                        .foregroundColor(duration == d ? .dmtBackground : .dmtMutedText)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(duration == d ? Color.dmtGold : Color.clear)
                                }
                                .clipShape(Capsule())
                            }
                        }
                        .padding(4)
                        .background(Color.clear)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
                    }

                    FormSection(label: "Recurrence") {
                        HStack(spacing: 0) {
                            ForEach(recurrences, id: \.self) { r in
                                Button {
                                    recurrence = r
                                } label: {
                                    Text(r.capitalized)
                                        .font(.dmtLabel(9))
                                        .tracking(1)
                                        .foregroundColor(recurrence == r ? .dmtBackground : .dmtMutedText)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(recurrence == r ? Color.dmtGold : Color.clear)
                                }
                                .clipShape(Capsule())
                            }
                        }
                        .padding(4)
                        .background(Color.clear)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
                    }

                    FormSection(label: "Notes (optional)") {
                        TextEditor(text: $notes)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                    }

                    if showWarning {
                        Text(warningMessage)
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtCrimson)
                            .padding(.horizontal, AppTheme.paddingLarge)
                    }

                    Button(action: save) {
                        Text("Schedule Lesson".uppercased())
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
                .padding(.top, AppTheme.paddingLarge)
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("New Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.dmtMutedText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        showWarning = false
        guard let student = selectedStudent else {
            warningMessage = "Please select a student."
            showWarning = true
            return
        }
        let vm = CalendarViewModel(context: viewContext)
        vm.addLesson(student: student,
                     date: date,
                     duration: duration,
                     recurrence: recurrence,
                     notes: notes)
        dismiss()
    }
}

#Preview {
    AddLessonSheet(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
