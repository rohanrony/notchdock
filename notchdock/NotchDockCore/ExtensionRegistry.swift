import Foundation

class ExtensionRegistry {
    private(set) var availableExtensions: [any NotchDockExtension] = []
    
    init() {}
    
    func register(_ ext: any NotchDockExtension) {
        availableExtensions.append(ext)
    }
}
