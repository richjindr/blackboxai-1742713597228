import SwiftUI

struct RoomDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var roomViewModel: RoomViewModel
    @ObservedObject var room: Room
    
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    @State private var editedName: String = ""
    @State private var editedCompassDirection: Double = 0
    @State private var editedType: RoomType = .livingRoom
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: room.roomType.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                        .frame(width: 60, height: 60)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(room.displayName)
                            .font(.headline)
                        Text(room.roomType.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Orientace oken")) {
                HStack {
                    Text("Světová strana:")
                    Spacer()
                    Text(getCompassDirectionText(room.compassDirection))
                        .foregroundColor(.secondary)
                }
            }
            
            if !room.plantsArray.isEmpty {
                Section(header: Text("Rostliny v místnosti")) {
                    ForEach(room.plantsArray) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            PlantRow(plant: plant)
                        }
                    }
                }
            } else {
                Section {
                    Text("V této místnosti zatím nejsou žádné rostliny")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Detail místnosti")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { isEditing = true }) {
                        Label("Upravit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        Label("Smazat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresited: $isEditing) {
            RoomEditView(
                roomViewModel: roomViewModel,
                room: room,
                isPresented: $isEditing
            )
        }
        .alert("Smazat místnost?", isPresented: $showingDeleteConfirmation) {
            Button("Zrušit", role: .cancel) {}
            Button("Smazat", role: .destructive) {
                roomViewModel.deleteRoom(room)
                dismiss()
            }
        } message: {
            Text("Rostliny v této místnosti zůstanou v aplikaci, ale budou bez přiřazené místnosti.")
        }
    }
}

struct RoomEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var roomViewModel: RoomViewModel
    @ObservedObject var room: Room
    @Binding var isPresented: Bool
    
    @State private var editedName: String = ""
    @State private var editedCompassDirection: Double = 0
    @State private var editedType: RoomType = .livingRoom
    
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Základní informace")) {
                    TextField("Název místnosti", text: $editedName)
                    
                    Picker("Typ místnosti", selection: $editedType) {
                        ForEach(RoomType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Orientace oken")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Světová strana: ")
                            Text(getCompassDirectionText(editedCompassDirection))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $editedCompassDirection,
                            in: 0...360,
                            step: 1
                        ) {
                            Text("Světová strana")
                        } minimumValueLabel: {
                            Image(systemName: "arrow.up")
                                .rotationEffect(.degrees(-90))
                        } maximumValueLabel: {
                            Image(systemName: "arrow.up")
                                .rotationEffect(.degrees(270))
                        }
                    }
                }
            }
            .navigationTitle("Upravit místnost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zrušit") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uložit") {
                        saveRoom()
                    }
                }
            }
            .alert("Chyba", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
            .onAppear {
                editedName = room.name ?? ""
                editedCompassDirection = room.compassDirection
                editedType = room.roomType
            }
        }
    }
    
    private func saveRoom() {
        guard !editedName.isEmpty else {
            showValidationError("Zadejte název místnosti")
            return
        }
        
        roomViewModel.updateRoom(
            room: room,
            name: editedName,
            compassDirection: editedCompassDirection,
            type: editedType
        )
        
        isPresented = false
    }
    
    private func showValidationError(_ message: String) {
        validationErrorMessage = message
        showingValidationError = true
    }
}

private func getCompassDirectionText(_ direction: Double) -> String {
    switch direction {
    case 0...22.5, 337.5...360:
        return "Sever"
    case 22.5...67.5:
        return "Severovýchod"
    case 67.5...112.5:
        return "Východ"
    case 112.5...157.5:
        return "Jihovýchod"
    case 157.5...202.5:
        return "Jih"
    case 202.5...247.5:
        return "Jihozápad"
    case 247.5...292.5:
        return "Západ"
    case 292.5...337.5:
        return "Severozápad"
    default:
        return "Neznámý směr"
    }
}

struct PlantRow: View {
    @ObservedObject var plant: Plant
    
    var body: some View {
        HStack {
            if let id = plant.scientificName {
                if let image = UIImage(named: id) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.green)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading) {
                Text(plant.customName ?? plant.scientificName ?? "Neznámá rostlina")
                    .font(.body)
                
                if let nextWatering = plant.nextWatering {
                    Text("Další zálivka: \(nextWatering.formattedForWatering())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct RoomDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let room = Room.create(
            in: context,
            name: "Obývací pokoj",
            compassDirection: 180,
            type: .livingRoom
        )
        NavigationView {
            RoomDetailView(
                roomViewModel: RoomViewModel(context: context),
                room: room
            )
        }
    }
}