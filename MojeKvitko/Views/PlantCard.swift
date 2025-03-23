import SwiftUI

struct PlantCard: View {
    @ObservedObject var plant: Plant
    
    var body: some View {
        NavigationLink(destination: PlantDetailView(plant: plant, roomViewModel: RoomViewModel(context: plant.managedObjectContext!))) {
            VStack(spacing: 8) {
                // Plant Image
                if let id = plant.scientificName {
                    if let image = UIImage(named: id) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                    } else {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                            .padding(30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Plant Names
                    Text(plant.customName ?? plant.scientificName ?? "")
                        .font(.headline)
                        .lineLimit(1)
                    
                    // Room Name
                    if let room = plant.room {
                        Text(room.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Next Watering
                    if let nextWatering = plant.nextWatering {
                        Text("Zálivka: \(nextWatering.formattedForWatering())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct PlantCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let plant = Plant(context: context)
        plant.customName = "Test Plant"
        plant.scientificName = "Test Scientific Name"
        
        return PlantCard(plant: plant)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}