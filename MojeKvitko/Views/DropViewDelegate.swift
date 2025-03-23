import SwiftUI

struct DropViewDelegate: DropDelegate {
    let item: Plant
    let items: [Plant]
    @Binding var draggedItem: Plant?
    let moveAction: (IndexSet, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else {
            return false
        }
        
        if let fromIndex = items.firstIndex(of: draggedItem),
           let toIndex = items.firstIndex(of: item) {
            if fromIndex != toIndex {
                moveAction(IndexSet(integer: fromIndex), toIndex)
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
}

struct NoOpDropDelegate: DropDelegate {
    func performDrop(info: DropInfo) -> Bool { false }
}