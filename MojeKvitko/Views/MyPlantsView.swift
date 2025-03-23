import SwiftUI

struct MyPlantsView: View {
    @ObservedObject var viewModel: PlantViewModel
    @State private var showingAddPlant = false
    @State private var draggedItem: Plant?
    
    private let columns = [
        GridItem(.flexible(), spacing: AppDimensions.gridSpacing),
        GridItem(.flexible(), spacing: AppDimensions.gridSpacing)
    ]
    
    var body: some View {
        ScrollView {
            if viewModel.plants.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "leaf.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(AppColors.primary)
                    
                    Text("Zatím nemáte žádné rostliny")
                        .font(AppFonts.headline)
                    
                    Text("Klikněte na + pro přidání nové rostliny")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: AppDimensions.gridSpacing) {
                    ForEach(viewModel.plants) { plant in
                        PlantCard(plant: plant)
                            .onDrag {
                                self.draggedItem = plant
                                return NSItemProvider(object: String(plant.orderIndex) as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: plant, items: viewModel.plants, draggedItem: $draggedItem) { from, to in
                                withAnimation {
                                    viewModel.movePlant(from: from, to: to)
                                }
                            })
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Moje rostliny")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPlant = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                }
            }
        }
        .sheet(isPresented: $showingAddPlant) {
            NavigationView {
                PlantSearchView(viewModel: viewModel)
            }
        }
        .onAppear {
            // Refresh plants when view appears
            viewModel.fetchPlants()
        }
    }
}

// MARK: - Plant Card View
struct PlantCard: View {
    @ObservedObject var plant: Plant
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack {
                if let id = plant.scientificName {
                    if let image = UIImage(named: id) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: AppDimensions.plantCardHeight * 0.7)
                            .clipped()
                    } else {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: AppDimensions.plantCardHeight * 0.4)
                            .foregroundColor(.green)
                    }
                } else {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: AppDimensions.plantCardHeight * 0.4)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.customName ?? plant.scientificName ?? "Neznámá rostlina")
                        .font(AppFonts.headline)
                        .lineLimit(1)
                    
                    if let nextWatering = plant.nextWatering {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text(nextWatering.formattedForWatering())
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .plantCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                PlantDetailView(plant: plant)
            }
        }
    }
}

// MARK: - Drop Delegate
struct DropViewDelegate: DropDelegate {
    let item: Plant
    let items: [Plant]
    @Binding var draggedItem: Plant?
    let reorderAction: (IndexSet, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else {
            return false
        }
        
        if let fromIndex = items.firstIndex(of: draggedItem),
           let toIndex = items.firstIndex(of: item) {
            if fromIndex != toIndex {
                reorderAction(IndexSet(integer: fromIndex), toIndex)
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem,
              let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: item) else {
            return
        }
        
        if fromIndex != toIndex {
            withAnimation {
                reorderAction(IndexSet(integer: fromIndex), toIndex)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// MARK: - Preview Provider
struct MyPlantsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            MyPlantsView(viewModel: PlantViewModel(context: context))
        }
    }
}