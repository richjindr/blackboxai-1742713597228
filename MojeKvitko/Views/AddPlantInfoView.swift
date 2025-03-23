import SwiftUI

struct AddPlantInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel
    let plantInfo: PlantInfo
    
    // Form fields
    @State private var customName: String = ""
    @State private var height: Double = 10
    @State private var potSize: Double = 6
    @State private var potType: String = "T"
    @State private var lastWatering: Date = Date()
    @State private var lastFertilizing: Date = Date()
    @State private var substrateType: String = "S"
    @State private var distanceFromWindow: String = "blizko"
    @State private var humidity: String = "standard"
    
    // Validation
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    private let heightValues: [Double] = Array(stride(from: 10, through: 300, by: 10))
    private let potSizeValues: [Double] = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]
    
    var body: some View {
        Form {
            Section(header: Text("Základní informace")) {
                VStack(alignment: .leading) {
                    Text("Vědecký název")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(plantInfo.name)
                        .font(AppFonts.body)
                        .italic()
                }
                
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
        .navigationTitle("Nová rostlina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Zrušit") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Uložit") {
                    savePlant()
                }
            }
        }
        .alert("Chyba", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationErrorMessage)
        }
    }
    
    private func savePlant() {
        // Validate form
        guard !customName.isEmpty else {
            showValidationError("Zadejte vlastní název rostliny")
            return
        }
        
        // Add plant
        viewModel.addPlant(
            plantInfo: plantInfo,
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
        
        // Dismiss both the add plant view and the search view
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name("DismissPlantSearch"), object: nil)
        }
    }
    
    private func showValidationError(_ message: String) {
        validationErrorMessage = message
        showingValidationError = true
    }
}

// MARK: - Preview Provider
struct AddPlantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
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
        
        NavigationView {
            AddPlantInfoView(viewModel: PlantViewModel(context: context), plantInfo: samplePlant)
        }
    }
}