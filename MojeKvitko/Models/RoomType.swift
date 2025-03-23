import Foundation
import SwiftUI

enum RoomType: String, CaseIterable, Identifiable {
    case livingRoom = "livingRoom"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case hallway = "hallway"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .livingRoom: return "Obývací pokoj"
        case .bedroom: return "Ložnice"
        case .kitchen: return "Kuchyně"
        case .bathroom: return "Koupelna"
        case .hallway: return "Chodba"
        }
    }
    
    var icon: String {
        switch self {
        case .livingRoom: return "sofa"
        case .bedroom: return "bed.double"
        case .kitchen: return "cooktop"
        case .bathroom: return "shower"
        case .hallway: return "door.left.hand.open"
        }
    }
}

enum PlantSortOption: String, CaseIterable, Identifiable {
    case custom = "custom"
    case alphabetical = "alphabetical"
    case type = "type"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .custom: return "Vlastní"
        case .alphabetical: return "Podle abecedy"
        case .type: return "Podle druhu"
        }
    }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case allPlants = "allPlants"
    case byRoom = "byRoom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .allPlants: return "Všechny rostliny"
        case .byRoom: return "Podle místností"
        }
    }
}