import SwiftUI

struct PlantEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel
    @ObservedObject var plant: Plant
    let plantInfo: PlantInfo
    
    // Form fields
    @State private var customName: String
    @State private var height: Double
    @State private var potSize: Double
    @State private var potType: String
    @State private var lastWatering: Date
    @State private var lastFertilizing: Date
    @State private var substrateType: String
    @State private var distanceFromWindow: String
    @State private var humidity: String
    
    // Validation
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    private let heightValues: [Double] = Array(stride(from: 10, through: 300, by: 10))
    private let potSizeValues: [Double] = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]
    
    init(viewModel: PlantViewModel, plant: Plant, plantInfo: PlantInfo) {
        self.viewModel = viewModel
        self.plant = plant
        self.plantInfo = plantInfo
        
        // Initialize state variables with current plant values
        _customName = State(initialValue: plant.customName ?? "")
        _height = State(initialValue: plant.height)
        _potSize = State(initialValue: plant.potSize)
        _potType = State(initialValue: plant.potType ?? "T")
        _lastWatering = State(initialValue: plant.lastWatering ?? Date())
        _lastFertilizing = State(initialValue: plant.lastFertilizing ?? Date())
        _substrateType = State(initialValue: plant.substrateType ?? "S")
        _distanceFromWindow = State(initialValue: plant.distanceFromWindow ?? "blizko")
        _humidity = State(initialValue: plant.humidity ?? "standard")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Základní informace")) {
                TextField("Vlastní název", text: $customName)
                
                // Height Slider
                VStack(alignment: .leading) {
                    Text("Výška rostliny: \(Int(height)) cm")
                    Slider(value: $height, in: 10...300, step: 10)
                }
                
                // Pot Size Slider
                VStack(alignment: .leading) {
                    Text("Velikost květináče: \(Int(potSize)) cm")
                    Slider(value: $potSize, in: 6...30, step: 2)
                }
                
                // Pot Type
                Picker("Typ květináče", selection: $potType) {
                    Text("Terakotový").tag("T")
                    Text("Plastový").tag("P")
                }
            }
            
            Section(header: Text("Péče")) {
                DatePicker("Poslední zálivka",
                          selection: $lastWatering,
                          displayedComponents: [.date])
                
                DatePicker("Poslední hnojení",
                          selection: $lastFertilizing,
                          displayedComponents: [.date])
                
                Picker("Typ substrátu", selection: $substrateType) {
                    Text("Standardní").tag("S")
                    Text("Lehký").tag("L")
                    Text("Těžký").tag("T")
                }
            }
            
            Section(header: Text("Umístění")) {
                Picker("Vzdálenost od okna", selection: $distanceFromWindow) {
                    Text("Blízko (0-0,5 m)").tag("blizko")
                    Text("Středně (1-2 m)").tag("stredne")
                    Text("Daleko (3+ m)").tag("daleko")
                }
                
                Picker("Vlhkost vzduchu", selection: $humidity) {
                    Text("Standardní").tag("standard")
                    Text("Nižší").tag("nižší")
                }
            }
        }
        .navigationTitle("Upravit rostlinu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Zrušit") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Uložit") {
                    updatePlant()
                }
            }
        }
        .alert("Chyba", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationErrorMessage)
        }
    }
    
    private func updatePlant() {
        // Validate form
        guard !customName.isEmpty else {
            showValidationError("Zadejte vlastní název rostliny")
            return
        }
        
        // Update plant
        viewModel.updatePlant(
            plant: plant,
            customName: customName,
            height: height,
            potSize: potSize,
            potType: potType,
            lastWatering: lastWatering,
            lastFertilizing: lastFertilizing,
            substrateType: substrateType,
            distanceFromWindow: distanceFromWindow,
            humidity: humidity
        )
        
        dismiss()
    }
    
    private func showValidationError(_ message: String) {
        validationErrorMessage = message
        showingValidationError = true
    }
}

// MARK: - Preview Provider
struct PlantEditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let plant = Plant(context: context)
        plant.customName = "Preview Plant"
        plant.scientificName = "Monstera deliciosa"
        plant.height = 100
        plant.potSize = 16
        plant.potType = "T"
        plant.lastWatering = Date()
        plant.nextWatering = Date().addingTimeInterval(86400 * 3)
        
        let samplePlant = PlantInfo(
            id: "1",
            name: "Sample Plant",
            watering: WateringInfo(
                summer: SeasonWateringInfo(
                    blizko: PotTypeInfo(T_L: "3-4", T_S: "4-5", T_T: "5-6", P_L: "4-5", P_S: "5-6", P_T: "6-7"),
                    stredne: PotTypeInfo(T_L: "4-5", T_S: "5-6", T_T: "6-7", P_L: "5-6", P_S: "6-7", P_T: "7-8"),
                    daleko: PotTypeInfo(T_L: "5-6", T_S: "6-7", T_T: "7-8", P_L: "6-7", P_S: "7-8", P_T: "8-9")
                ),
                spring_autumn: SeasonWateringInfo(
                    blizko: PotTypeInfo(T_L: "5-6", T_S: "6-7", T_T: "7-8", P_L: "6-7", P_S: "7-8", P_T: "8-9"),
                    stredne: PotTypeInfo(T_L: "6-7", T_S: "7-8", T_T: "8-9", P_L: "7-8", P_S: "8-9", P_T: "9-10"),
                    daleko: PotTypeInfo(T_L: "7-8", T_S: "8-9", T_T: "9-10", P_L: "8-9", P_S: "9-10", P_T: "10-12")
                ),
                winter: SeasonWateringInfo(
                    blizko: PotTypeInfo(T_L: "10-12", T_S: "12-14", T_T: "14-16", P_L: "12-14", P_S: "14-16", P_T: "16-18"),
                    stredne: PotTypeInfo(T_L: "12-14", T_S: "14-16", T_T: "16-18", P_L: "14-16", P_S: "16-18", P_T: "18-20"),
                    daleko: PotTypeInfo(T_L: "14-16", T_S: "16-18", T_T: "18-20", P_L: "16-18", P_S: "18-20", P_T: "20-22")
                )
            )
        )
        
        return NavigationView {
            PlantEditView(viewModel: PlantViewModel(context: context), plant: plant, plantInfo: samplePlant)
        }
    }
}