import Foundation

class WateringCalculator {
    static let shared = WateringCalculator()
    
    private init() {}
    
    func calculateNextWateringDate(
        plant: PlantInfo,
        distance: String,
        potType: String,
        substrateType: String,
        humidity: String,
        lastWateringDate: Date
    ) -> Date {
        // Get the current season
        let season = PlantInfo.getCurrentSeason()
        
        // Get the appropriate watering info based on season
        let seasonInfo: SeasonWateringInfo
        switch season {
        case "summer":
            seasonInfo = plant.watering.summer
        case "winter":
            seasonInfo = plant.watering.winter
        default:
            seasonInfo = plant.watering.spring_autumn
        }
        
        // Get distance-specific info
        let distanceInfo: PotTypeInfo
        switch distance {
        case "blizko":
            distanceInfo = seasonInfo.blizko
        case "stredne":
            distanceInfo = seasonInfo.stredne
        default:
            distanceInfo = seasonInfo.daleko
        }
        
        // Get the interval string based on pot type and substrate
        let intervalString = distanceInfo.getInterval(potType: potType, substrateType: substrateType)
        
        // Parse interval string (e.g., "3-4") and get lower bound
        let components = intervalString.split(separator: "-")
        var interval = Int(components[0]) ?? 7 // Default to 7 if parsing fails
        
        // Adjust interval based on humidity
        if humidity == "nižší" {
            interval = max(1, interval - 1)
        }
        
        // Calculate next watering date
        let calendar = Calendar.current
        guard let nextDate = calendar.date(byAdding: .day, value: interval, to: lastWateringDate) else {
            return Date() // Fallback to current date if calculation fails
        }
        
        return nextDate
    }
    
    func formatCountdown(to date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if date < now {
            return "Překročeno"
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: date)
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        return String(format: "%02d:%02d:%02d", days, hours, minutes)
    }
    
    func isWateringOverdue(date: Date) -> Bool {
        return date < Date()
    }
    
    // Helper method to get watering dates for calendar view
    func getWateringDatesForMonth(date: Date, plants: [Plant]) -> Set<Date> {
        let calendar = Calendar.current
        var dates = Set<Date>()
        
        // Get start of month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return dates
        }
        
        // Add all watering dates that fall within this month
        for plant in plants {
            if let nextWatering = plant.nextWatering,
               nextWatering >= startOfMonth && nextWatering <= endOfMonth {
                // Normalize to start of day for comparison
                if let normalizedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: nextWatering)) {
                    dates.insert(normalizedDate)
                }
            }
        }
        
        return dates
    }
    
    // Get plants that need watering on a specific date
    func getPlantsNeedingWatering(on date: Date, plants: [Plant]) -> [Plant] {
        let calendar = Calendar.current
        return plants.filter { plant in
            guard let nextWatering = plant.nextWatering else { return false }
            return calendar.isDate(date, inSameDayAs: nextWatering)
        }
    }
}

// Extension to help with date formatting
extension Date {
    func formattedForWatering() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: self)
    }
}