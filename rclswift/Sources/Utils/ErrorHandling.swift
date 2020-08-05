import RclC

public enum RclSwiftError: Error {
    case optionsAlreadyInitialized
    case invalidArgument
    case badAllocation
    case internalError
    case unknownRclError

    internal init(errorCode: rcl_ret_t) {
        switch errorCode {
        case RCL_RET_ALREADY_INIT:
            self = .optionsAlreadyInitialized
        case RCL_RET_INVALID_ARGUMENT:
            self = .invalidArgument
        case RCL_RET_BAD_ALLOC:
            self = .badAllocation
        case RCL_RET_ERROR:
            self = .internalError
        default:
            self = .unknownRclError
        }
    }
}

func throwIfError(errorCode: rcl_ret_t) throws {
    switch errorCode {
    case RCL_RET_OK:
        return
    default:
        throw RclSwiftError(errorCode: errorCode)
    }
}