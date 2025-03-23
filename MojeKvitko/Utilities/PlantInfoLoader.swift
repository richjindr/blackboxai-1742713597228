import Foundation

class PlantInfoLoader {
    static let shared = PlantInfoLoader()
    
    private var loadedPlants: [PlantInfo]?
    
    private init() {
        // Force a fresh load on initialization
        loadedPlants = nil
        _ = loadPlants()
    }
    
    func loadPlants() -> [PlantInfo] {
        // Return cached plants if available
        if let loadedPlants = loadedPlants {
            return loadedPlants
        }
        
        print("Attempting to load plants...")
        
        // First try to load from Data directory
        if let dataUrl = Bundle.main.url(forResource: "plants", withExtension: "json", subdirectory: "Data") {
            print("Found plants.json in Data directory")
            do {
                let data = try Data(contentsOf: dataUrl)
                let decoder = JSONDecoder()
                let plants = try decoder.decode([PlantInfo].self, from: data) // Changed to decode array directly
                loadedPlants = plants
                print("Successfully loaded \(plants.count) plants from Data directory")
                print("Plant names: \(plants.map { $0.name }.joined(separator: ", "))")
                return plants
            } catch {
                print("Error loading plants from Data directory: \(error)")
                if let dataString = try? String(contentsOf: dataUrl, encoding: .utf8) {
                    print("JSON content: \(dataString)")
                }
            }
        } else {
            print("Could not find plants.json in Data directory")
        }
        
        // Try loading from bundle root
        if let bundleUrl = Bundle.main.url(forResource: "plants", withExtension: "json") {
            print("Found plants.json in bundle root")
            do {
                let data = try Data(contentsOf: bundleUrl)
                let decoder = JSONDecoder()
                let plants = try decoder.decode([PlantInfo].self, from: data) // Changed to decode array directly
                loadedPlants = plants
                print("Successfully loaded \(plants.count) plants from bundle root")
                print("Plant names: \(plants.map { $0.name }.joined(separator: ", "))")
                return plants
            } catch {
                print("Error loading plants from bundle root: \(error)")
                if let dataString = try? String(contentsOf: bundleUrl, encoding: .utf8) {
                    print("JSON content: \(dataString)")
                }
            }
        } else {
            print("Could not find plants.json in bundle root")
        }
        
        // Try loading from documents directory as last resort
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("plants.json")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("Found plants.json in documents directory")
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    let plants = try decoder.decode([PlantInfo].self, from: data) // Changed to decode array directly
                    loadedPlants = plants
                    print("Successfully loaded \(plants.count) plants from documents")
                    print("Plant names: \(plants.map { $0.name }.joined(separator: ", "))")
                    return plants
                } catch {
                    print("Error loading plants from documents: \(error)")
                }
            } else {
                print("plants.json not found in documents directory, attempting to copy from bundle")
                // Try to copy the file from bundle to documents
                if let bundleUrl = Bundle.main.url(forResource: "plants", withExtension: "json") {
                    do {
                        try FileManager.default.copyItem(at: bundleUrl, to: fileURL)
                        print("Successfully copied plants.json to documents directory")
                        // Try loading again
                        let data = try Data(contentsOf: fileURL)
                        let decoder = JSONDecoder()
                        let plants = try decoder.decode([PlantInfo].self, from: data) // Changed to decode array directly
                        loadedPlants = plants
                        print("Successfully loaded \(plants.count) plants after copying")
                        return plants
                    } catch {
                        print("Error copying/loading plants.json: \(error)")
                    }
                }
            }
        }
        
        print("All attempts to load plants.json failed, using hardcoded data")
        
        // If all attempts fail, return hardcoded data
        let hardcodedPlants = [
            PlantInfo(
                id: "1",
                name: "Monstera deliciosa",
                watering: createDefaultWateringInfo()
            ),
            PlantInfo(
                id: "2",
                name: "Monstera adansonii",
                watering: createDefaultWateringInfo()
            ),
            PlantInfo(
                id: "3",
                name: "Raphidophora tetrasperma",
                watering: createDefaultWateringInfo()
            )
        ]
        
        loadedPlants = hardcodedPlants
        return hardcodedPlants
    }
    
    private func createDefaultWateringInfo() -> WateringInfo {
        let defaultPotInfo = PotTypeInfo(
            T_L: "7-8", T_S: "8-9", T_T: "9-10",
            P_L: "8-9", P_S: "9-10", P_T: "10-11"
        )
        let defaultSeasonInfo = SeasonWateringInfo(
            blizko: defaultPotInfo,
            stredne: defaultPotInfo,
            daleko: defaultPotInfo
        )
        return WateringInfo(
            summer: defaultSeasonInfo,
            spring_autumn: defaultSeasonInfo,
            winter: defaultSeasonInfo
        )
    }
    
    func searchPlants(query: String) -> [PlantInfo] {
        let plants = loadPlants()
        if query.isEmpty {
            return plants
        }
        return plants.filter { plant in
            plant.name.lowercased().contains(query.lowercased())
        }
    }
    
    func getPlant(byId id: String) -> PlantInfo? {
        return loadPlants().first { $0.id == id }
    }
}