import SwiftUI

struct MyPlantsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: PlantViewModel
    @StateObject private var roomViewModel: RoomViewModel
    @State private var showingAddPlant = false
    @State private var draggedItem: Plant?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: PlantViewModel(context: context))
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.plants) { plant in
                        PlantCard(plant: plant)
                            .onDrag {
                                self.draggedItem = plant
                                return NSItemProvider()
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                item: plant,
                                items: viewModel.plants,
                                draggedItem: $draggedItem,
                                moveAction: viewModel.movePlant
                            ))
                    }
                }
                .padding()
            }
            .navigationTitle("Moje rostliny")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                PlantSearchView()
            }
        }
        .onAppear {
            viewModel.fetchPlants()
            roomViewModel.fetchRooms()
        }
    }
}

struct MyPlantsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlantsView(context: PersistenceController.preview.container.viewContext)
    }
}