import Foundation
import CoreData
import SwiftUI

class RoomViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var showingError = false
    @Published var errorMessage = ""
    
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchRooms()
    }
    
    // MARK: - Fetch Operations
    
    func fetchRooms() {
        let request = Room.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Room.name, ascending: true)]
        
        do {
            rooms = try viewContext.fetch(request)
            print("Fetched \(rooms.count) rooms")
        } catch {
            showError("Chyba při načítání místností: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Room Operations
    
    func addRoom(
        name: String,
        compassDirection: Double,
        type: RoomType
    ) {
        viewContext.performAndWait {
            let room = Room.create(
                in: viewContext,
                name: name,
                compassDirection: compassDirection,
                type: type
            )
            
            do {
                try viewContext.save()
                print("Successfully added room: \(name)")
                fetchRooms()
            } catch {
                showError("Chyba při ukládání místnosti: \(error.localizedDescription)")
            }
        }
    }
    
    func updateRoom(
        room: Room,
        name: String,
        compassDirection: Double,
        type: RoomType
    ) {
        viewContext.performAndWait {
            room.name = name
            room.compassDirection = compassDirection
            room.type = type.rawValue
            
            do {
                try viewContext.save()
                print("Successfully updated room: \(name)")
                fetchRooms()
            } catch {
                showError("Chyba při ukládání změn: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteRoom(_ room: Room) {
        viewContext.performAndWait {
            // Remove room reference from all plants
            let plants = room.plantsArray
            for plant in plants {
                plant.room = nil
            }
            
            viewContext.delete(room)
            
            do {
                try viewContext.save()
                print("Successfully deleted room")
                fetchRooms()
            } catch {
                showError("Chyba při mazání místnosti: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Plant Assignment
    
    func assignPlant(_ plant: Plant, to room: Room?) {
        viewContext.performAndWait {
            plant.room = room
            
            do {
                try viewContext.save()
                print("Successfully assigned plant to room")
                fetchRooms()
            } catch {
                showError("Chyba při přiřazování rostliny: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getRoom(byId id: UUID) -> Room? {
        return rooms.first { $0.id == id }
    }
    
    func getRoomName(for room: Room?) -> String {
        return room?.displayName ?? "Bez místnosti"
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showingError = true
            print("Error: \(message)")
        }
    }
}