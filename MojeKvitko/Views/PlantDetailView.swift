import SwiftUI

struct PlantDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var plant: Plant
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingMarkAsDeadAlert = false
    @State private var showingActionSheet = false
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var plantViewModel: PlantViewModel {
        PlantViewModel(context: viewContext)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDimensions.spacing) {
                // Plant Image
                if let id = plant.scientificName {
                    Image(id)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                } else {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.green)
                }
                
                // Plant Names
                VStack(spacing: 4) {
                    Text(plant.scientificName ?? "")
                        .font(AppFonts.headline)
                        .italic()
                    
                    Text(plant.customName ?? "")
                        .font(AppFonts.title)
                }
                .padding(.horizontal)
                
                // Next Watering Info
                if let nextWatering = plant.nextWatering {
                    WateringInfoCard(date: nextWatering)
                }
                
                // Plant Details
                PlantDetailsCard(plant: plant)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingActionSheet = true }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Akce", isPresented: $showingActionSheet) {
            Button("Upravit") {
                showingEditSheet = true
            }
            
            Button("Označit jako mrtvou", role: .destructive) {
                showingMarkAsDeadAlert = true
            }
            
            Button("Smazat", role: .destructive) {
                showingDeleteAlert = true
            }
        }
        .alert("Smazat rostlinu?", isPresented: $showingDeleteAlert) {
            Button("Smazat", role: .destructive) {
                deletePlant()
            }
            Button("Zrušit", role: .cancel) {}
        } message: {
            Text("Opravdu chcete smazat tuto rostlinu? Tuto akci nelze vrátit zpět.")
        }
        .alert("Označit jako mrtvou?", isPresented: $showingMarkAsDeadAlert) {
            Button("Označit", role: .destructive) {
                markPlantAsDead()
            }
            Button("Zrušit", role: .cancel) {}
        } message: {
            Text("Opravdu chcete označit tuto rostlinu jako mrtvou?")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let plantInfo = PlantInfoLoader.shared.getPlant(byId: plant.scientificName ?? "") {
                NavigationView {
                    PlantEditView(viewModel: plantViewModel, plant: plant, plantInfo: plantInfo)
                }
            }
        }
        .onReceive(timer) { _ in
            // Force view update to refresh countdown timer
            plantViewModel.objectWillChange.send()
        }
    }
    
    private func deletePlant() {
        plantViewModel.deletePlant(plant)
        dismiss()
    }
    
    private func markPlantAsDead() {
        // Here you could implement additional logic for marking a plant as dead
        // For now, we'll just delete it
        deletePlant()
    }
}

// MARK: - Watering Info Card
struct WateringInfoCard: View {
    let date: Date
    
    private var isOverdue: Bool {
        WateringCalculator.shared.isWateringOverdue(date: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Další zálivka")
                .font(AppFonts.headline)
            
            Text(date.formattedForWatering())
                .font(AppFonts.body)
            
            Text(WateringCalculator.shared.formatCountdown(to: date))
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(isOverdue ? AppColors.error : AppColors.text)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isOverdue ? AppColors.error.opacity(0.1) : AppColors.secondaryBackground)
        .cornerRadius(AppDimensions.cornerRadius)
    }
}

// MARK: - Plant Details Card
struct PlantDetailsCard: View {
    let plant: Plant
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacing) {
            DetailRow(title: "Výška", value: "\(Int(plant.height)) cm")
            DetailRow(title: "Velikost květináče", value: "\(Int(plant.potSize)) cm")
            DetailRow(title: "Typ květináče", value: plant.potType == "T" ? "Terakotový" : "Plastový")
            DetailRow(title: "Poslední zálivka", value: plant.lastWatering?.formattedForWatering() ?? "Neznámé")
            DetailRow(title: "Poslední hnojení", value: plant.lastFertilizing?.formattedForWatering() ?? "Neznámé")
            DetailRow(title: "Typ substrátu", value: {
                switch plant.substrateType {
                case "S": return "Standardní"
                case "L": return "Lehký"
                case "T": return "Těžký"
                default: return "Neznámý"
                }
            }())
            DetailRow(title: "Vzdálenost od okna", value: {
                switch plant.distanceFromWindow {
                case "blizko": return "Blízko (0-0,5 m)"
                case "stredne": return "Středně (1-2 m)"
                case "daleko": return "Daleko (3+ m)"
                default: return "Neznámá"
                }
            }())
            DetailRow(title: "Vlhkost vzduchu", value: plant.humidity == "standard" ? "Standardní" : "Nižší")
        }
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppDimensions.cornerRadius)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.secondaryText)
            Spacer()
            Text(value)
                .foregroundColor(AppColors.text)
        }
    }
}

// MARK: - Preview Provider
struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let plant = Plant(context: context)
        plant.customName = "Preview Plant"
        plant.scientificName = "Monstera deliciosa"
        plant.height = 100
        plant.potSize = 16
        plant.potType = "T"
        plant.lastWatering = Date()
        plant.nextWatering = Date().addingTimeInterval(86400 * 3)
        
        return NavigationView {
            PlantDetailView(plant: plant)
        }
    }
}