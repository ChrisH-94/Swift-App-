import SwiftUI

struct CalendarGrid: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var showDaySheet: Bool

    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: AppTheme.paddingMedium) {
            // Month navigation
            HStack {
                Button {
                    viewModel.advanceMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(.dmtGold)
                }

                Spacer()

                Text(viewModel.monthTitle.uppercased())
                    .font(.dmtLabel(11))
                    .tracking(3)
                    .foregroundColor(.dmtPrimaryText)

                Spacer()

                Button {
                    viewModel.advanceMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(.dmtGold)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day.uppercased())
                        .font(.dmtLabel(8))
                        .tracking(1)
                        .foregroundColor(.dmtMutedText)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading empty cells
                ForEach(0..<viewModel.firstWeekdayOfMonth, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }

                // Day cells
                ForEach(viewModel.daysInDisplayedMonth, id: \.self) { date in
                    DayCell(
                        date: date,
                        isToday: calendar.isDateInToday(date),
                        isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                        lessons: viewModel.lessonsOnDate(date)
                    )
                    .onTapGesture {
                        viewModel.selectDate(date)
                        if !viewModel.lessonsForSelectedDate.isEmpty {
                            showDaySheet = true
                        }
                    }
                }
            }
        }
        .padding(AppTheme.paddingMedium)
        .dmtCard()
    }
}

// MARK: - Day Cell
private struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let lessons: [Lesson]

    private var dayNumber: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if isToday {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(Color.dmtGold, lineWidth: 1)
                }
                Text(dayNumber)
                    .font(.dmtBody(13))
                    .foregroundColor(isToday ? .dmtGold : .dmtPrimaryText)
            }
            .frame(width: 32, height: 32)

            // Lesson chips
            if !lessons.isEmpty {
                HStack(spacing: 2) {
                    ForEach(lessons.prefix(2), id: \.id) { _ in
                        Circle()
                            .fill(Color.dmtGold)
                            .frame(width: 4, height: 4)
                    }
                    if lessons.count > 2 {
                        Text("+")
                            .font(.system(size: 6))
                            .foregroundColor(.dmtGold)
                    }
                }
            } else {
                Color.clear.frame(height: 4)
            }
        }
        .frame(height: 44)
        .background(isSelected ? Color.dmtSurface : Color.clear)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

#Preview {
    CalendarGrid(viewModel: CalendarViewModel(context: PersistenceController.preview.container.viewContext),
                 showDaySheet: .constant(false))
        .padding()
        .background(Color.dmtBackground)
}
