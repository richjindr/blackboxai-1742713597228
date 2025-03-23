import Foundation
import CoreData

extension Plant {
    var displayName: String {
        return customName ?? scientificName ?? "Neznámá rostlina"
    }
    
    var isOverdueForWatering: Bool {
        guard let nextWatering = nextWatering else { return false }
        return nextWatering < Date()
    }
    
    static func deadPlantsFetchRequest() -> NSFetchRequest<Plant> {
        let request = NSFetchRequest<Plant>(entityName: "Plant")
        request.predicate = NSPredicate(format: "isDead == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Plant.customName, ascending: true)]
        return request
    }
    
    static func create(
        in context: NSManagedObjectContext,
        id: UUID = UUID(),
        scientificName: String,
        customName: String,
        height: Double,
        potSize: Double,
        potType: String,
        lastWatering: Date,
        lastFertilizing: Date,
        substrateType: String,
        distanceFromWindow: String,
        humidity: String,
        room: Room? = nil
    ) -> Plant {
        let plant = Plant(context: context)
        plant.id = id
        plant.scientificName = scientificName
        plant.customName = customName
        plant.height = height
        plant.potSize = potSize
        plant.potType = potType
        plant.lastWatering = lastWatering
        plant.lastFertilizing = lastFertilizing
        plant.substrateType = substrateType
        plant.distanceFromWindow = distanceFromWindow
        plant.humidity = humidity
        plant.orderIndex = 0
        plant.isDead = false
        plant.room = room
        return plant
    }
}