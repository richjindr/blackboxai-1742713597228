import SwiftUI

struct AddRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var roomViewModel: RoomViewModel
    
    @State private var roomName = ""
    @State private var compassDirection: Double = 0
    @State private var selectedType: RoomType = .livingRoom
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Základní informace")) {
                    TextField("Název místnosti", text: $roomName)
                    
                    Picker("Typ místnosti", selection: $selectedType) {
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
                            Text(getCompassDirectionText())
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $compassDirection,
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
            .navigationTitle("Nová místnost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zrušit") {
                        dismiss()
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
        }
    }
    
    private func getCompassDirectionText() -> String {
        switch compassDirection {
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
    
    private func saveRoom() {
        guard !roomName.isEmpty else {
            showValidationError("Zadejte název místnosti")
            return
        }
        
        roomViewModel.addRoom(
            name: roomName,
            compassDirection: compassDirection,
            type: selectedType
        )
        
        dismiss()
    }
    
    private func showValidationError(_ message: String) {
        validationErrorMessage = message
        showingValidationError = true
    }
}

struct AddRoomView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        AddRoomView(roomViewModel: RoomViewModel(context: context))
    }
}