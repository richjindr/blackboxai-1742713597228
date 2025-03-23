import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var plantViewModel: PlantViewModel
    @State private var notificationTime = Date()
    @State private var showingSaveConfirmation = false
    @State private var showingDeadPlants = false
    
    init(context: NSManagedObjectContext) {
        _plantViewModel = StateObject(wrappedValue: PlantViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Upozornění")) {
                    DatePicker("Čas upozornění na zálivku",
                              selection: $notificationTime,
                              displayedComponents: .hourAndMinute)
                        .onChange(of: notificationTime) { newValue in
                            NotificationManager.shared.updateNotificationTime(to: newValue)
                            showingSaveConfirmation = true
                        }
                }
                
                Section(header: Text("Zemřelé rostliny")) {
                    Button {
                        showingDeadPlants = true
                    } label: {
                        HStack {
                            Text("Hřbitov rostlin")
                            Spacer()
                            Text("\(plantViewModel.deadPlants.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("O aplikaci")) {
                    HStack {
                        Text("Verze")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Nastavení")
            .onAppear {
                // Load current notification time
                if let savedTime = UserDefaults.standard.object(forKey: "NotificationTime") as? Date {
                    notificationTime = savedTime
                }
                plantViewModel.fetchDeadPlants()
            }
            .alert("Nastavení uloženo", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showingDeadPlants) {
                PlantCemeteryView(plants: plantViewModel.deadPlants)
            }
        }
    }
}

struct PlantCemeteryView: View {
    let plants: [Plant]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(plants) { plant in
                VStack(alignment: .leading) {
                    Text(plant.displayName)
                        .font(.headline)
                    if let scientificName = plant.scientificName {
                        Text(scientificName)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Hřbitov rostlin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hotovo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(context: PersistenceController.preview.container.viewContext)
    }
}