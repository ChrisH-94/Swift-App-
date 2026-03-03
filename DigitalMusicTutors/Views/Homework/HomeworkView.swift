import SwiftUI

struct HomeworkView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeworkViewModel
    @State private var showAddTask = false

    init() {
        _viewModel = StateObject(wrappedValue: HomeworkViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter bar
                FilterBar(selected: $viewModel.filterStatus)
                    .padding(.horizontal, AppTheme.paddingLarge)
                    .padding(.vertical, AppTheme.paddingMedium)

                Divider().background(Color.dmtBorder)

                if viewModel.filteredTasks.isEmpty {
                    EmptyStateView("No tasks assigned yet.", icon: "checklist")
                } else {
                    List {
                        ForEach(viewModel.filteredTasks, id: \.id) { task in
                            TaskRow(task: task)
                                .listRowBackground(Color.dmtCard)
                                .listRowSeparatorTint(Color.dmtBorder)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.dmtCrimson)

                                    Button {
                                        viewModel.markComplete(task)
                                    } label: {
                                        Label("Done", systemImage: "checkmark")
                                    }
                                    .tint(.dmtSage)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.dmtBackground)
                }
            }
            .background(Color.dmtBackground.ignoresSafeArea())
            .navigationTitle("Homework")
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
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(.dmtGold)
                    }
                }
            }
            .sheet(isPresented: $showAddTask, onDismiss: { viewModel.fetchTasks() }) {
                AddTaskSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                viewModel.fetchTasks()
                viewModel.updateOverdueStatuses()
            }
        }
    }
}

// MARK: - Filter Bar
private struct FilterBar: View {
    @Binding var selected: HomeworkViewModel.TaskFilter

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeworkViewModel.TaskFilter.allCases, id: \.self) { filter in
                Button {
                    selected = filter
                } label: {
                    Text(filter.rawValue.uppercased())
                        .font(.dmtLabel(9))
                        .tracking(1.5)
                        .foregroundColor(selected == filter ? .dmtBackground : .dmtMutedText)
                        .padding(.horizontal, AppTheme.paddingMedium)
                        .padding(.vertical, 8)
                        .background(selected == filter ? Color.dmtGold : Color.clear)
                }
                .clipShape(Capsule())
            }
        }
        .padding(4)
        .background(Color.dmtCard)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
    }
}

// MARK: - Task Row
private struct TaskRow: View {
    let task: HomeworkTask

    var body: some View {
        HStack(spacing: AppTheme.paddingMedium) {
            Circle()
                .fill(statusColor)
                .frame(width: AppTheme.statusDotSize, height: AppTheme.statusDotSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled Task")
                    .font(.dmtBody(14))
                    .foregroundColor(.dmtPrimaryText)

                HStack(spacing: AppTheme.paddingSmall) {
                    Text(task.student?.name ?? "")
                        .font(.dmtBody(11))
                        .foregroundColor(.dmtMutedText)

                    if let due = task.dueDate {
                        Text("· Due \(due, style: .date)")
                            .font(.dmtBody(11))
                            .foregroundColor(.dmtMutedText)
                    }
                }
            }

            Spacer()

            StatusBadge(status: task.status ?? "pending")
        }
        .padding(.vertical, AppTheme.paddingSmall)
    }

    private var statusColor: Color {
        switch task.status {
        case "complete": return .dmtSage
        case "overdue":  return .dmtCrimson
        default:         return .dmtGold
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String

    private var label: String {
        status.uppercased()
    }

    private var color: Color {
        switch status {
        case "complete": return .dmtSage
        case "overdue":  return .dmtCrimson
        default:         return .dmtGold
        }
    }

    var body: some View {
        Text(label)
            .font(.dmtLabel(8))
            .tracking(1)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(color, lineWidth: AppTheme.borderWidth)
            )
    }
}

#Preview {
    HomeworkView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
