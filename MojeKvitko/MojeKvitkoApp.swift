import SwiftUI

@main
struct MojeKvitkoApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Request notification authorization on app launch
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    persistenceController.saveContext()
                }
        }
    }
}