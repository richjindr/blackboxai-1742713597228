import SwiftUI

struct PlantDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var plant: Plant
    @ObservedObject var roomViewModel: RoomViewModel
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingMarkDeadAlert = false
    @State private var showingActionSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Plant Image
                if let id = plant.scientificName {
                    if let image = UIImage(named: id) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    } else {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)
                    }
                }
                
                // Plant Names
                VStack(spacing: 8) {
                    Text(plant.scientificName ?? "")
                        .font(.title2)
                        .italic()
                    Text(plant.customName ?? "")
                        .font(.title3)
                }
                .padding(.horizontal)
                
                // Next Watering
                if let nextWatering = plant.nextWatering {
                    VStack(spacing: 4) {
                        Text("Další zálivka")
                            .font(.headline)
                        Text(nextWatering.formattedForWatering())
                            .foregroundColor(plant.isOverdueForWatering ? .red : .primary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                // Plant Details
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "Velikost rostliny", value: "\(Int(plant.height)) cm")
                    DetailRow(title: "Velikost květináče", value: "\(Int(plant.potSize)) cm")
                    DetailRow(title: "Typ květináče", value: plant.potType == "T" ? "Terakotový" : "Plastový")
                    DetailRow(title: "Poslední zálivka", value: plant.lastWatering?.formattedForWatering() ?? "-")
                    DetailRow(title: "Poslední hnojení", value: plant.lastFertilizing?.formattedForWatering() ?? "-")
                    DetailRow(title: "Typ substrátu", value: {
                        switch plant.substrateType {
                        case "S": return "Standardní"
                        case "L": return "Lehký"
                        case "T": return "Těžký"
                        default: return "-"
                        }
                    }())
                    DetailRow(title: "Vzdálenost od okna", value: {
                        switch plant.distanceFromWindow {
                        case "blizko": return "Blízko (0-0.5m)"
                        case "stredne": return "Středně (1-2m)"
                        case "daleko": return "Daleko (3m+)"
                        default: return "-"
                        }
                    }())
                    DetailRow(title: "Vlhkost vzduchu", value: plant.humidity == "nizsi" ? "Nižší" : "Normální")
                    if let room = plant.room {
                        DetailRow(title: "Místnost", value: room.displayName)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingActionSheet = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Možnosti"), buttons: [
                .default(Text("Upravit")) { showingEditSheet = true },
                .destructive(Text("Označit jako zemřelou")) { showingMarkDeadAlert = true },
                .destructive(Text("Smazat")) { showingDeleteAlert = true },
                .cancel(Text("Zrušit"))
            ])
        }
        .alert("Smazat rostlinu?", isPresented: $showingDeleteAlert) {
            Button("Smazat", role: .destructive) {
                deletePlant()
            }
            Button("Zrušit", role: .cancel) { }
        } message: {
            Text("Opravdu chcete smazat tuto rostlinu? Tuto akci nelze vrátit zpět.")
        }
        .alert("Označit jako zemřelou?", isPresented: $showingMarkDeadAlert) {
            Button("Označit", role: .destructive) {
                markPlantAsDead()
            }
            Button("Zrušit", role: .cancel) { }
        } message: {
            Text("Opravdu chcete označit tuto rostlinu jako zemřelou?")
        }
        .sheet(isPresented: $showingEditSheet) {
            PlantEditView(viewModel: PlantViewModel(context: viewContext), plant: plant)
        }
    }
    
    private func deletePlant() {
        let viewModel = PlantViewModel(context: viewContext)
        viewModel.deletePlant(plant)
        dismiss()
    }
    
    private func markPlantAsDead() {
        plant.isDead = true
        try? viewContext.save()
        dismiss()
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let plant = Plant.create(
            in: context,
            scientificName: "Monstera deliciosa",
            customName: "Sample Plant",
            height: 100,
            potSize: 12,
            potType: "T",
            lastWatering: Date(),
            lastFertilizing: Date(),
            substrateType: "S",
            distanceFromWindow: "blizko",
            humidity: "standard"
        )
        
        return NavigationView {
            PlantDetailView(
                plant: plant,
                roomViewModel: RoomViewModel(context: context)
            )
        }
    }
}