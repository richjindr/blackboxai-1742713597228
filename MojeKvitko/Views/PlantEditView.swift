import SwiftUI

struct PlantEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel
    @ObservedObject var plant: Plant
    @StateObject private var roomViewModel: RoomViewModel
    
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
    @State private var selectedRoom: Room?
    
    // UI State
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(viewModel: PlantViewModel, plant: Plant) {
        self.viewModel = viewModel
        self.plant = plant
        _roomViewModel = StateObject(wrappedValue: RoomViewModel(context: viewModel.viewContext))
        
        // Initialize state with current plant values
        _customName = State(initialValue: plant.customName ?? "")
        _height = State(initialValue: plant.height)
        _potSize = State(initialValue: plant.potSize)
        _potType = State(initialValue: plant.potType ?? "T")
        _lastWatering = State(initialValue: plant.lastWatering ?? Date())
        _lastFertilizing = State(initialValue: plant.lastFertilizing ?? Date())
        _substrateType = State(initialValue: plant.substrateType ?? "S")
        _distanceFromWindow = State(initialValue: plant.distanceFromWindow ?? "blizko")
        _humidity = State(initialValue: plant.humidity ?? "standard")
        _selectedRoom = State(initialValue: plant.room)
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
    
    private func updatePlant() {
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
        
        // Update room separately to avoid potential conflicts
        if plant.room != selectedRoom {
            roomViewModel.assignPlant(plant, to: selectedRoom)
        }
        
        dismiss()
    }
}

struct PlantEditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = PlantViewModel(context: context)
        let plant = Plant.create(
            in: context,
            scientificName: "Monstera deliciosa",
            customName: "Sample Plant",
            height: 100,
            potSize: 12,
            potType: "T",
            lastWatering: Date(),
            lastFertilizing: Date(),
            substrateType: "S",
            distanceFromWindow: "blizko",
            humidity: "standard"
        )
        
        return PlantEditView(viewModel: viewModel, plant: plant)
    }
}