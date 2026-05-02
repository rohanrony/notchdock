import Foundation
import StoreKit
import Combine

class PurchaseManager: ObservableObject {
    @Published var unlockedProducts: Set<String> = []
    
    func owns(_ productID: String?) -> Bool {
        guard let id = productID else { return false }
        return unlockedProducts.contains(id)
    }
    
    // For Phase 3/4 testing
    func unlockMock(_ productID: String) {
        unlockedProducts.insert(productID)
    }
}
