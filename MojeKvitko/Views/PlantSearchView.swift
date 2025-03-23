import SwiftUI

struct PlantSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel
    @State private var searchText = ""
    @State private var plants: [PlantInfo] = []
    @State private var selectedPlant: PlantInfo?
    @State private var showingAddPlantSheet = false
    
    var body: some View {
        List {
            if plants.isEmpty {
                Text("Načítání rostlin...")
                    .foregroundColor(AppColors.secondaryText)
            } else {
                ForEach(filteredPlants) { plant in
                    PlantSearchRow(plant: plant)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPlant = plant
                            showingAddPlantSheet = true
                        }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Hledat rostlinu")
        .navigationTitle("Přidat rostlinu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Zrušit") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingAddPlantSheet) {
            if let plant = selectedPlant {
                NavigationView {
                    AddPlantInfoView(viewModel: viewModel, plantInfo: plant)
                }
            }
        }
        .onAppear {
            // Load plants when view appears
            loadPlants()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissPlantSearch"))) { _ in
            dismiss()
        }
    }
    
    private func loadPlants() {
        // Load plants in the background
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedPlants = PlantInfoLoader.shared.loadPlants()
            DispatchQueue.main.async {
                self.plants = loadedPlants
                print("Loaded \(loadedPlants.count) plants")
            }
        }
    }
    
    private var filteredPlants: [PlantInfo] {
        if searchText.isEmpty {
            return plants
        }
        return plants.filter { plant in
            plant.name.lowercased().contains(searchText.lowercased())
        }
    }
}

struct PlantSearchRow: View {
    let plant: PlantInfo
    
    var body: some View {
        HStack {
            if let image = UIImage(named: plant.id) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
                    .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(AppFonts.body)
                
                Text("ID: \(plant.id)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview Provider
struct PlantSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            PlantSearchView(viewModel: PlantViewModel(context: context))
        }
    }
}