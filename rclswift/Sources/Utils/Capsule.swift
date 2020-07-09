class Capsule<Type> {
    var enclosed: Type
    private var cleanupHandler: (inout Type) -> Void
    init(_ object: Type, onDestruct cleanup: @escaping (inout Type) -> Void) {
        enclosed = object
        cleanupHandler = cleanup
    }
    
    deinit {
        cleanupHandler(&enclosed)
    }
}