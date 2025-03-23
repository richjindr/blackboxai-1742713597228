import SwiftUI

struct SettingsView: View {
    @State private var notificationTime = Date()
    @State private var showingSaveConfirmation = false
    
    private let notificationManager = NotificationManager.shared
    
    init() {
        let (hour, minute) = notificationManager.getNotificationTime()
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        _notificationTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Upozornění na zálivku")) {
                DatePicker("Čas upozornění",
                          selection: $notificationTime,
                          displayedComponents: .hourAndMinute)
                    .onChange(of: notificationTime) { newValue in
                        saveNotificationTime(date: newValue)
                    }
                
                Text("Upozornění přijde v nastavený čas v den, kdy má být rostlina zalita")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Section(header: Text("O aplikaci")) {
                VStack(alignment: .leading, spacing: AppDimensions.spacing) {
                    Text("MojeKvítko")
                        .font(AppFonts.headline)
                    
                    Text("Verze 1.0")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Aplikace pro správu zálivky pokojových rostlin")
                        .font(AppFonts.body)
                        .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Nastavení")
        .alert("Nastavení uloženo", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func saveNotificationTime(date: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        notificationManager.updateNotificationTime(to: hour, minute: minute)
        
        // Reschedule all notifications to the new time
        let context = PersistenceController.shared.container.viewContext
        let viewModel = PlantViewModel(context: context)
        notificationManager.rescheduleNotifications(for: viewModel.plants)
        
        showingSaveConfirmation = true
    }
}

// MARK: - Preview Provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}