import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MojeKvitko")
        
        // Enable persistent history tracking
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Preview Helper
extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController()
        let viewContext = controller.container.viewContext
        
        // Add sample data for previews
        let samplePlant = Plant.create(
            in: viewContext,
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
        samplePlant.nextWatering = Date().addingDays(7)
        
        let sampleRoom = Room(context: viewContext)
        sampleRoom.id = UUID()
        sampleRoom.name = "Living Room"
        sampleRoom.type = RoomType.livingRoom.rawValue
        sampleRoom.compassDirection = 180
        
        samplePlant.room = sampleRoom
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

// MARK: - Fetch Request Helpers
extension NSManagedObjectContext {
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try fetch(request)
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
}