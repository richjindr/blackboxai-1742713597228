import Foundation

extension Date {
    func formattedForWatering() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: self)
    }
    
    static func getCurrentSeason() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        
        switch (month, day) {
        case (3, 20...31), (4, _), (5, _), (6, 1...20):
            return "spring_autumn"
        case (6, 21...30), (7, _), (8, _), (9, 1...22):
            return "summer"
        case (9, 23...30), (10, _), (11, _), (12, 1...20):
            return "spring_autumn"
        default:
            return "winter"
        }
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isInFuture() -> Bool {
        return self > Date()
    }
}