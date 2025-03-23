import SwiftUI

struct PlantSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var plantLoader = PlantInfoLoader.shared
    @State private var searchText = ""
    @State private var selectedPlant: PlantInfo?
    @State private var showingAddPlantInfo = false
    
    var filteredPlants: [PlantInfo] {
        if searchText.isEmpty {
            return plantLoader.getAllPlants()
        } else {
            return plantLoader.searchPlants(query: searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Hledat rostlinu", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Plant list
                List(filteredPlants) { plant in
                    Button(action: {
                        selectedPlant = plant
                        showingAddPlantInfo = true
                    }) {
                        HStack {
                            if let image = UIImage(named: plant.id) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "leaf.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                            }
                            
                            Text(plant.name)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Přidat rostlinu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPlantInfo) {
                if let plant = selectedPlant {
                    AddPlantInfoView(
                        viewModel: PlantViewModel(context: PersistenceController.shared.container.viewContext),
                        plantInfo: plant
                    )
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissPlantSearch"))) { _ in
                dismiss()
            }
        }
    }
}

struct PlantSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PlantSearchView()
    }
}