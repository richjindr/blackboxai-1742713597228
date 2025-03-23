import SwiftUI

struct WateringView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var selectedDate = Date()
    @State private var showingWateringConfirmation: Plant?
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calendar
                CalendarView(
                    selectedDate: $selectedDate,
                    markedDates: viewModel.getWateringDatesForMonth(date: selectedDate),
                    onMonthChange: { date in
                        selectedDate = date
                    }
                )
                .padding()
                
                // Watering List
                VStack(spacing: 0) {
                    ForEach(groupedWaterings.keys.sorted(), id: \.self) { date in
                        if let plants = groupedWaterings[date] {
                            WateringDateSection(
                                date: date,
                                plants: plants,
                                onWatered: { plant in
                                    showingWateringConfirmation = plant
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Zálivky")
        .alert("Označit jako zalitou?", isPresented: Binding(
            get: { showingWateringConfirmation != nil },
            set: { if !$0 { showingWateringConfirmation = nil } }
        )) {
            Button("Zrušit", role: .cancel) {}
            Button("Označit") {
                if let plant = showingWateringConfirmation {
                    viewModel.markPlantAsWatered(plant)
                }
                showingWateringConfirmation = nil
            }
        }
        .onAppear {
            viewModel.fetchPlants()
        }
    }
    
    private var groupedWaterings: [Date: [Plant]] {
        var groups: [Date: [Plant]] = [:]
        
        for plant in viewModel.plants where !plant.isDead {
            if let nextWatering = plant.nextWatering {
                // Normalize to start of day
                let normalizedDate = calendar.startOfDay(for: nextWatering)
                if normalizedDate >= calendar.startOfDay(for: Date()) {
                    var plants = groups[normalizedDate] ?? []
                    plants.append(plant)
                    groups[normalizedDate] = plants
                }
            }
        }
        
        return groups
    }
}

struct WateringDateSection: View {
    let date: Date
    let plants: [Plant]
    let onWatered: (Plant) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date.formattedForWatering())
                .font(.headline)
                .padding(.vertical, 8)
            
            ForEach(plants) { plant in
                HStack {
                    if let id = plant.scientificName {
                        if let image = UIImage(named: id) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                                .padding(8)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(plant.customName ?? plant.scientificName ?? "Neznámá rostlina")
                            .font(.body)
                        if let room = plant.room {
                            Text(room.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { onWatered(plant) }) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    let markedDates: Set<Date>
    let onMonthChange: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let dayNames = ["Po", "Út", "St", "Čt", "Pá", "So", "Ne"]
    
    var body: some View {
        VStack {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Day Names
            HStack {
                ForEach(dayNames, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek)) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        CalendarDay(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isMarked: markedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }),
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: selectedDate).capitalized
    }
    
    private var days: [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: start)!.count
        
        let firstWeekday = calendar.component(.weekday, from: start)
        let weekdayOffset = (firstWeekday + 5) % 7 // Adjust for Monday start
        
        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: start) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            onMonthChange(newDate)
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            onMonthChange(newDate)
        }
    }
}

struct CalendarDay: View {
    let date: Date
    let isSelected: Bool
    let isMarked: Bool
    let isToday: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            Text("\(calendar.component(.day, from: date))")
                .foregroundColor(textColor)
        }
        .overlay(
            Circle()
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
        )
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isMarked {
            return .blue.opacity(0.2)
        }
        return .clear
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        }
        return .primary
    }
}

struct WateringView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            WateringView(viewModel: PlantViewModel(context: context))
        }
    }
}