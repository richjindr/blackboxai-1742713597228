import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var plantViewModel: PlantViewModel
    @StateObject private var roomViewModel: RoomViewModel
    
    init(context: NSManagedObjectContext) {
        _plantViewModel = StateObject(wrappedValue: PlantViewModel(context: context))
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(context: context))
    }
    
    var body: some View {
        TabView {
            NavigationView {
                MyPlantsView(
                    viewModel: plantViewModel,
                    roomViewModel: roomViewModel
                )
            }
            .tabItem {
                Label("Moje rostliny", systemImage: "leaf.fill")
            }
            
            NavigationView {
                WateringView(viewModel: plantViewModel)
            }
            .tabItem {
                Label("Zálivky", systemImage: "drop.fill")
            }
            
            NavigationView {
                SettingsView(context: viewContext)
            }
            .tabItem {
                Label("Nastavení", systemImage: "gear")
            }
        }
        .alert("Chyba", isPresented: $plantViewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(plantViewModel.errorMessage)
        }
        .alert("Chyba", isPresented: $roomViewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(roomViewModel.errorMessage)
        }
    }
}

struct AppDimensions {
    static let gridSpacing: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 24
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ContentView(context: context)
            .environment(\.managedObjectContext, context)
    }
}