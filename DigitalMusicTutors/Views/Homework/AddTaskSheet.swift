import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var priority: Int16 = 1
    @State private var selectedStudent: Student?
    @State private var showWarning = false
    @State private var warningMessage = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Student.name, ascending: true)],
        animation: .default
    ) private var students: FetchedResults<Student>

    let priorities = ["Low", "Medium", "High"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                    // Student picker
                    FormSection(label: "Student") {
                        if students.isEmpty {
                            Text("No students yet — add one first.")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtMutedText)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.paddingSmall) {
                                    ForEach(students) { student in
                                        Button {
                                            selectedStudent = student
                                        } label: {
                                            Text(student.name ?? "")
                                                .font(.dmtBody(13))
                                                .foregroundColor(selectedStudent == student ? .dmtBackground : .dmtPrimaryText)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(selectedStudent == student ? Color.dmtGold : Color.dmtCard)
                                                .cornerRadius(AppTheme.cornerRadius)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                                        .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    FormSection(label: "Task Title") {
                        TextField("e.g. Practise Scales C Major", text: $title)
                            .font(.dmtBody(14))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                    }

                    FormSection(label: "Practice Notes") {
                        TextEditor(text: $description)
                            .font(.dmtBody(13))
                            .foregroundColor(.dmtPrimaryText)
                            .accentColor(.dmtGold)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                    }

                    FormSection(label: "Due Date") {
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accentColor(.dmtGold)
                            .colorScheme(.dark)
                    }

                    FormSection(label: "Priority") {
                        HStack(spacing: 0) {
                            ForEach(Array(priorities.enumerated()), id: \.offset) { idx, label in
                                Button {
                                    priority = Int16(idx)
                                } label: {
                                    Text(label.uppercased())
                                        .font(.dmtLabel(9))
                                        .tracking(1.5)
                                        .foregroundColor(priority == Int16(idx) ? .dmtBackground : .dmtMutedText)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(priority == Int16(idx) ? Color.dmtGold : Color.clear)
                                }
                                .clipShape(Capsule())
                            }
                        }
                        .padding(4)
                        .background(Color.dmtCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
                    }

                    if showWarning {
                        Text(warningMessage)
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtCrimson)
                            .padding(.horizontal, AppTheme.paddingLarge)
                    }

                    // Save button
                    Button(action: save) {
                        Text("Save Task".uppercased())
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
            .navigationTitle("New Task")
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
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            warningMessage = "Please enter a task title."
            showWarning = true
            return
        }
        guard let student = selectedStudent else {
            warningMessage = "Please select a student."
            showWarning = true
            return
        }

        let vm = HomeworkViewModel(context: viewContext)
        vm.addTask(title: title,
                   description: description,
                   dueDate: dueDate,
                   priority: priority,
                   student: student)
        dismiss()
    }
}

// MARK: - FormSection helper
struct FormSection<Content: View>: View {
    let label: String
    let content: () -> Content

    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
            Text(label.uppercased())
                .dmtLabel()

            content()
                .padding(AppTheme.paddingMedium)
                .background(Color.dmtCard)
                .cornerRadius(AppTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
                )
        }
        .padding(.horizontal, AppTheme.paddingLarge)
    }
}

#Preview {
    AddTaskSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
