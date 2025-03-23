import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleWateringNotification(for plant: Plant, at date: Date) {
        // Remove any existing notifications for this plant
        cancelNotification(for: plant)
        
        let content = UNMutableNotificationContent()
        content.title = "Čas na zálivku! 🌿"
        content.body = "Rostlina \(plant.customName ?? plant.scientificName ?? "Neznámá rostlina") potřebuje zalít"
        content.sound = .default
        
        // Create date components for the notification
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request with unique identifier for the plant
        let identifier = "watering-\(plant.id?.uuidString ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for plant: Plant) {
        let identifier = "watering-\(plant.id?.uuidString ?? UUID().uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateNotificationTime(to hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: "NotificationHour")
        UserDefaults.standard.set(minute, forKey: "NotificationMinute")
    }
    
    func getNotificationTime() -> (hour: Int, minute: Int) {
        let hour = UserDefaults.standard.integer(forKey: "NotificationHour")
        let minute = UserDefaults.standard.integer(forKey: "NotificationMinute")
        return (hour: hour == 0 ? 9 : hour, minute: minute) // Default to 9:00 if not set
    }
    
    // Reschedule all notifications for a specific day to the user's preferred time
    func rescheduleNotifications(for plants: [Plant]) {
        let (hour, minute) = getNotificationTime()
        
        for plant in plants {
            guard let nextWatering = plant.nextWatering else { continue }
            
            // Create new date with user's preferred time
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            var components = calendar.dateComponents([.year, .month, .day], from: nextWatering)
            components.hour = hour
            components.minute = minute
            
            if let newDate = calendar.date(from: components) {
                scheduleWateringNotification(for: plant, at: newDate)
            }
        }
    }
}