import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var plantViewModel: PlantViewModel
    @State private var selectedTab = 0
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _plantViewModel = StateObject(wrappedValue: PlantViewModel(context: context))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MyPlantsView(viewModel: plantViewModel)
            }
            .tabItem {
                Image(systemName: "leaf.fill")
                Text("Moje rostliny")
            }
            .tag(0)
            
            NavigationView {
                WateringView(viewModel: plantViewModel)
            }
            .tabItem {
                Image(systemName: "drop.fill")
                Text("Zálivky")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Nastavení")
            }
            .tag(2)
        }
        .accentColor(.green)
        .alert("Chyba", isPresented: $plantViewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(plantViewModel.errorMessage)
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

// MARK: - Constants
struct AppColors {
    static let primary = Color.green
    static let secondary = Color.blue
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let error = Color.red
    static let text = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
}

struct AppDimensions {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 8
    static let iconSize: CGFloat = 24
    static let gridSpacing: CGFloat = 16
    static let plantCardHeight: CGFloat = 200
}

struct AppFonts {
    static let title = Font.title
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
}

// MARK: - Common View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppDimensions.padding)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppDimensions.cornerRadius)
            .shadow(radius: 2)
    }
}

struct PlantCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: AppDimensions.plantCardHeight)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppDimensions.cornerRadius)
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func plantCardStyle() -> some View {
        modifier(PlantCardStyle())
    }
}