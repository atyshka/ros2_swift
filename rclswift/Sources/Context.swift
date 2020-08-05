import RclC
import Dispatch

private func cleanupContext(context: inout rcl_context_t) {
    if (rcl_context_is_valid(&context)) {
        do {
            try throwIfError(errorCode: rcl_shutdown(&context))
        } catch {
            print("Failed to shutdown during context destruct!")
        }
    }
    do {
        try throwIfError(errorCode: rcl_context_fini(&context))
    } catch {
        print("Failed to finalize context during context destruct")
    }
}

public class Context {
    private var CContext = Capsule<rcl_context_t>(rcl_get_zero_initialized_context(), onDestruct: cleanupContext)
    private let serialQueue = DispatchQueue(label: "Context Queue")
    private var callbacks: [() -> Void] = []
    
    public var ok: Bool {
        get {
            return serialQueue.sync {
                return rcl_context_is_valid(&CContext.enclosed)
            }
        }
    }
    
    public init() {

    }

    public func startup(argc: Int32, argv: UnsafePointer<UnsafePointer<Int8>?>?) throws {
        try serialQueue.sync {
            var initOptions = rcl_get_zero_initialized_init_options()
            let allocator = rcutils_get_default_allocator()
            try throwIfError(errorCode: rcl_init_options_init(&initOptions, allocator))
            try throwIfError(errorCode: rcl_init(argc, argv, &initOptions, &CContext.enclosed))
        }
    }

    public func shutdown() throws {
        try serialQueue.sync {
            try throwIfError(errorCode: rcl_shutdown(&CContext.enclosed))
        }
    }
}