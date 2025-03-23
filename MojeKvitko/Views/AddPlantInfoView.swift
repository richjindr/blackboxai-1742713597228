import SwiftUI

struct AddPlantInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel
    @StateObject private var roomViewModel: RoomViewModel
    let plantInfo: PlantInfo
    
    // Form fields
    @State private var customName = ""
    @State private var height: Double = 100
    @State private var potSize: Double = 12
    @State private var potType = "T"
    @State private var lastWatering = Date()
    @State private var lastFertilizing = Date()
    @State private var substrateType = "S"
    @State private var distanceFromWindow = "blizko"
    @State private var humidity = "standard"
    @State private var selectedRoom: Room?
    
    // UI State
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(viewModel: PlantViewModel, plantInfo: PlantInfo) {
        self.viewModel = viewModel
        self.plantInfo = plantInfo
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(context: viewModel.viewContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Základní informace")) {
                    TextField("Vlastní název", text: $customName)
                    
                    VStack(alignment: .leading) {
                        Text("Velikost rostliny: \(Int(height)) cm")
                        Slider(value: $height, in: 10...300, step: 10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Velikost květináče: \(Int(potSize)) cm")
                        Slider(value: $potSize, in: 6...30, step: 2)
                    }
                }
                
                Section(header: Text("Typ květináče")) {
                    Picker("Typ květináče", selection: $potType) {
                        Text("Terakotový").tag("T")
                        Text("Plastový").tag("P")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Péče")) {
                    DatePicker("Poslední zálivka",
                              selection: $lastWatering,
                              displayedComponents: .date)
                    
                    DatePicker("Poslední hnojení",
                              selection: $lastFertilizing,
                              displayedComponents: .date)
                }
                
                Section(header: Text("Podmínky")) {
                    Picker("Typ substrátu", selection: $substrateType) {
                        Text("Standardní").tag("S")
                        Text("Lehký").tag("L")
                        Text("Těžký").tag("T")
                    }
                    
                    Picker("Vzdálenost od okna", selection: $distanceFromWindow) {
                        Text("Blízko (0-0.5m)").tag("blizko")
                        Text("Středně (1-2m)").tag("stredne")
                        Text("Daleko (3m+)").tag("daleko")
                    }
                    
                    Picker("Vlhkost vzduchu", selection: $humidity) {
                        Text("Normální").tag("standard")
                        Text("Nižší").tag("nizsi")
                    }
                }
                
                Section(header: Text("Místnost")) {
                    Picker("Vybrat místnost", selection: $selectedRoom) {
                        Text("Bez místnosti").tag(nil as Room?)
                        ForEach(roomViewModel.rooms) { room in
                            Text(room.displayName).tag(room as Room?)
                        }
                    }
                }
            }
            .navigationTitle("Přidat rostlinu")
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
            .alert("Chyba", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            roomViewModel.fetchRooms()
        }
    }
    
    private func savePlant() {
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
            humidity: humidity,
            room: selectedRoom
        )
        dismiss()
    }
}

struct AddPlantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = PlantViewModel(context: context)
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
        
        return AddPlantInfoView(viewModel: viewModel, plantInfo: samplePlant)
    }
}