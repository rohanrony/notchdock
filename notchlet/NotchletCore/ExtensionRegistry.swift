import Foundation

class ExtensionRegistry {
    private(set) var availableExtensions: [any NotchletExtension] = []
    
    init() {}
    
    func register(_ ext: any NotchletExtension) {
        availableExtensions.append(ext)
    }
}
