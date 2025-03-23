import SwiftUI

struct WateringView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var selectedDate = Date()
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: AppDimensions.spacing) {
            // Upcoming waterings list
            ScrollView {
                LazyVStack(spacing: AppDimensions.spacing) {
                    ForEach(viewModel.plants.filter { $0.nextWatering != nil }
                        .sorted { ($0.nextWatering ?? Date()) < ($1.nextWatering ?? Date()) }
                    ) { plant in
                        WateringCard(plant: plant)
                            .onTapGesture {
                                viewModel.markPlantAsWatered(plant)
                            }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Calendar view
            CalendarView(selectedDate: $selectedDate,
                        markedDates: viewModel.getWateringDatesForMonth(date: selectedDate))
        }
        .navigationTitle("Zálivky")
        .onReceive(timer) { _ in
            // Force view update to refresh countdown timers
            viewModel.objectWillChange.send()
        }
    }
}

// MARK: - Watering Card
struct WateringCard: View {
    let plant: Plant
    
    private var isOverdue: Bool {
        guard let nextWatering = plant.nextWatering else { return false }
        return WateringCalculator.shared.isWateringOverdue(date: nextWatering)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.customName ?? plant.scientificName ?? "Neznámá rostlina")
                    .font(AppFonts.headline)
                
                if let nextWatering = plant.nextWatering {
                    Text(nextWatering.formattedForWatering())
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(WateringCalculator.shared.formatCountdown(to: nextWatering))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(isOverdue ? AppColors.error : AppColors.text)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundColor(AppColors.primary)
        }
        .padding()
        .background(isOverdue ? AppColors.error.opacity(0.1) : AppColors.secondaryBackground)
        .cornerRadius(AppDimensions.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                .stroke(isOverdue ? AppColors.error : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Binding var selectedDate: Date
    let markedDates: Set<Date>
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Ne", "Po", "Út", "St", "Čt", "Pá", "So"]
    
    var body: some View {
        VStack(spacing: AppDimensions.spacing) {
            // Month selector
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(AppFonts.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Days of week
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                               isMarked: markedDates.contains { calendar.isDate($0, inSameDayAs: date) })
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Color.clear
                    }
                }
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppDimensions.cornerRadius)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: selectedDate)
    }
    
    private var days: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        
        var days = [Date?]()
        calendar.enumerateDates(startingAfter: dateInterval.start - 1,
                              matching: DateComponents(hour: 0, minute: 0, second: 0),
                              matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date > dateInterval.end {
                    stop = true
                } else {
                    days.append(calendar.isDate(date, equalTo: monthInterval.start, toGranularity: .month) ? date : nil)
                }
            }
        }
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isMarked: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(AppFonts.body)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                    }
                    if isMarked {
                        Circle()
                            .stroke(AppColors.primary, lineWidth: 1)
                    }
                }
            )
            .foregroundColor(isSelected ? .white : isMarked ? AppColors.primary : AppColors.text)
    }
}

// MARK: - Preview Provider
struct WateringView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            WateringView(viewModel: PlantViewModel(context: context))
        }
    }
}