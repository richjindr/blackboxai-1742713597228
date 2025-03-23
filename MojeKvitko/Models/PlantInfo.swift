import Foundation

struct PlantInfo: Codable, Identifiable {
    let id: String
    let name: String
    let watering: WateringInfo
    
    static func getCurrentSeason(date: Date = Date()) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch (month, day) {
        case (3, 20...31), (4, _), (5, _), (6, 1...20):  // Spring
            return "spring_autumn"
        case (6, 21...30), (7, _), (8, _), (9, 1...22):  // Summer
            return "summer"
        case (9, 23...30), (10, _), (11, _), (12, 1...20):  // Autumn
            return "spring_autumn"
        default:  // Winter (December 21 - March 19)
            return "winter"
        }
    }
}

struct WateringInfo: Codable {
    let summer: SeasonWateringInfo
    let spring_autumn: SeasonWateringInfo
    let winter: SeasonWateringInfo
}

struct SeasonWateringInfo: Codable {
    let blizko: PotTypeInfo
    let stredne: PotTypeInfo
    let daleko: PotTypeInfo
}

struct PotTypeInfo: Codable {
    let T_L: String  // Terakotový květináč, lehký substrát
    let T_S: String  // Terakotový květináč, standardní substrát
    let T_T: String  // Terakotový květináč, těžký substrát
    let P_L: String  // Plastový květináč, lehký substrát
    let P_S: String  // Plastový květináč, standardní substrát
    let P_T: String  // Plastový květináč, těžký substrát
    
    func getInterval(potType: String, substrateType: String) -> String {
        switch (potType, substrateType) {
            case ("T", "L"): return T_L
            case ("T", "S"): return T_S
            case ("T", "T"): return T_T
            case ("P", "L"): return P_L
            case ("P", "S"): return P_S
            case ("P", "T"): return P_T
            default: return "7"  // Default fallback interval
        }
    }
}

// MARK: - Helper Extensions

extension PlantInfo {
    var displayName: String {
        return name
    }
}

extension PotTypeInfo {
    func getIntervalRange(potType: String, substrateType: String) -> (min: Int, max: Int) {
        let intervalString = getInterval(potType: potType, substrateType: substrateType)
        let components = intervalString.split(separator: "-")
        
        guard components.count == 2,
              let min = Int(components[0]),
              let max = Int(components[1]) else {
            return (7, 7) // Default fallback
        }
        
        return (min, max)
    }
}

// MARK: - Identifiable Conformance

extension SeasonWateringInfo: Identifiable {
    var id: String {
        // Create a unique identifier based on the content
        return "\(blizko)\(stredne)\(daleko)"
    }
}

extension PotTypeInfo: Identifiable {
    var id: String {
        // Create a unique identifier based on the content
        return "\(T_L)\(T_S)\(T_T)\(P_L)\(P_S)\(P_T)"
    }
}