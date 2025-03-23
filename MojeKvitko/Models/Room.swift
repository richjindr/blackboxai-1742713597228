import Foundation
import CoreData

extension Room {
    var displayName: String {
        return name ?? "Neznámá místnost"
    }
    
    var plantsArray: [Plant] {
        let set = plants as? Set<Plant> ?? []
        return Array(set)
    }
    
    var roomType: RoomType {
        get {
            return RoomType(rawValue: type ?? "") ?? .livingRoom
        }
        set {
            type = newValue.rawValue
        }
    }
}