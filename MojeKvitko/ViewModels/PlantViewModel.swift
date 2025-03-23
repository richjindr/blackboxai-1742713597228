import Foundation
import CoreData
import SwiftUI

class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var searchText: String = ""
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private let viewContext: NSManagedObjectContext
    private let notificationManager = NotificationManager.shared
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchPlants()
        print("PlantViewModel initialized")
    }
    
    // MARK: - Fetch Operations
    
    func fetchPlants() {
        let request = NSFetchRequest<Plant>(entityName: "Plant")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Plant.orderIndex, ascending: true)]
        
        do {
            plants = try viewContext.fetch(request)
            print("Fetched \(plants.count) plants")
        } catch {
            showError("Chyba při načítání rostlin: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Plant Operations
    
    func addPlant(
        plantInfo: PlantInfo,
        customName: String,
        height: Double,
        potSize: Double,
        potType: String,
        lastWatering: Date,
        lastFertilizing: Date,
        substrateType: String,
        distanceFromWindow: String,
        humidity: String
    ) {
        viewContext.performAndWait {
            let plant = Plant(context: viewContext)
            plant.id = UUID()
            plant.scientificName = plantInfo.id // Store the ID from plantInfo
            plant.customName = customName
            plant.height = height
            plant.potSize = potSize
            plant.potType = potType
            plant.lastWatering = lastWatering
            plant.lastFertilizing = lastFertilizing
            plant.substrateType = substrateType
            plant.distanceFromWindow = distanceFromWindow
            plant.humidity = humidity
            plant.orderIndex = Int16(plants.count)
            
            // Calculate next watering date
            updateNextWateringDate(for: plant, plantInfo: plantInfo)
            
            do {
                try viewContext.save()
                print("Successfully added plant: \(customName)")
                
                // Schedule notification for the new plant
                if let nextWatering = plant.nextWatering {
                    notificationManager.scheduleWateringNotification(
                        for: plant,
                        at: nextWatering
                    )
                }
                
                // Refresh the plants list
                DispatchQueue.main.async {
                    self.fetchPlants()
                }
            } catch {
                showError("Chyba při ukládání rostliny: \(error.localizedDescription)")
            }
        }
    }
    
    func updatePlant(
        plant: Plant,
        customName: String,
        height: Double,
        potSize: Double,
        potType: String,
        lastWatering: Date,
        lastFertilizing: Date,
        substrateType: String,
        distanceFromWindow: String,
        humidity: String
    ) {
        viewContext.performAndWait {
            plant.customName = customName
            plant.height = height
            plant.potSize = potSize
            plant.potType = potType
            plant.lastWatering = lastWatering
            plant.lastFertilizing = lastFertilizing
            plant.substrateType = substrateType
            plant.distanceFromWindow = distanceFromWindow
            plant.humidity = humidity
            
            // Get plant info and update next watering date
            if let scientificName = plant.scientificName,
               let plantInfo = PlantInfoLoader.shared.getPlant(byId: scientificName) {
                updateNextWateringDate(for: plant, plantInfo: plantInfo)
            }
            
            do {
                try viewContext.save()
                print("Successfully updated plant: \(customName)")
                
                // Update notification
                if let nextWatering = plant.nextWatering {
                    notificationManager.scheduleWateringNotification(
                        for: plant,
                        at: nextWatering
                    )
                }
                
                // Refresh the plants list
                DispatchQueue.main.async {
                    self.fetchPlants()
                }
            } catch {
                showError("Chyba při ukládání změn: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePlant(_ plant: Plant) {
        viewContext.performAndWait {
            // Cancel any pending notifications
            notificationManager.cancelNotification(for: plant)
            
            viewContext.delete(plant)
            
            do {
                try viewContext.save()
                print("Successfully deleted plant")
                
                // Update order indices
                DispatchQueue.main.async {
                    self.reorderPlants()
                }
            } catch {
                showError("Chyba při mazání rostliny: \(error.localizedDescription)")
            }
        }
    }
    
    func markPlantAsWatered(_ plant: Plant) {
        viewContext.performAndWait {
            plant.lastWatering = Date()
            
            // Get plant info and update next watering date
            if let scientificName = plant.scientificName,
               let plantInfo = PlantInfoLoader.shared.getPlant(byId: scientificName) {
                updateNextWateringDate(for: plant, plantInfo: plantInfo)
            }
            
            do {
                try viewContext.save()
                print("Successfully marked plant as watered")
                
                // Update notification
                if let nextWatering = plant.nextWatering {
                    notificationManager.scheduleWateringNotification(
                        for: plant,
                        at: nextWatering
                    )
                }
                
                // Refresh the plants list
                DispatchQueue.main.async {
                    self.fetchPlants()
                }
            } catch {
                showError("Chyba při aktualizaci zálivky: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateNextWateringDate(for plant: Plant, plantInfo: PlantInfo) {
        guard let lastWatering = plant.lastWatering,
              let potType = plant.potType,
              let substrateType = plant.substrateType,
              let distanceFromWindow = plant.distanceFromWindow,
              let humidity = plant.humidity else {
            return
        }
        
        let nextDate = WateringCalculator.shared.calculateNextWateringDate(
            plant: plantInfo,
            distance: distanceFromWindow,
            potType: potType,
            substrateType: substrateType,
            humidity: humidity,
            lastWateringDate: lastWatering
        )
        
        plant.nextWatering = nextDate
    }
    
    func reorderPlants() {
        viewContext.performAndWait {
            for (index, plant) in plants.enumerated() {
                plant.orderIndex = Int16(index)
            }
            
            do {
                try viewContext.save()
                print("Successfully reordered plants")
                fetchPlants()
            } catch {
                showError("Chyba při změně pořadí: \(error.localizedDescription)")
            }
        }
    }
    
    func movePlant(from source: IndexSet, to destination: Int) {
        plants.move(fromOffsets: source, toOffset: destination)
        reorderPlants()
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showingError = true
            print("Error: \(message)")
        }
    }
    
    // MARK: - Watering Schedule
    
    func getPlantsNeedingWatering(on date: Date) -> [Plant] {
        return WateringCalculator.shared.getPlantsNeedingWatering(on: date, plants: plants)
    }
    
    func getWateringDatesForMonth(date: Date) -> Set<Date> {
        return WateringCalculator.shared.getWateringDatesForMonth(date: date, plants: plants)
    }
}