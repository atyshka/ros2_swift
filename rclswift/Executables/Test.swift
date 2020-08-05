import RclSwift
import Foundation

var context = Context()
CommandLine.unsafeArgv.withMemoryRebound(to: UnsafePointer<Int8>?.self, capacity: Int(CommandLine.argc)) { ptr in
        do {
            try context.startup(argc: CommandLine.argc, argv: ptr)
            print("Successful init")
        } catch {
            print("Unexpected error: \(error).")
        }
    }

do {
    try context.shutdown()
    print("Successful shutdown")
} catch {
    print("Unexpected error: \(error).")
}

