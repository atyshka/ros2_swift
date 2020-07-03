import CRcl

class Node {
    var rcl_node: UnsafeMutablePointer<rcl_node_t>
    init(name: String, namespace: String) {
        self.rcl_node = UnsafeMutablePointer<rcl_node_t>.allocate(capacity: 1)
        self.rcl_node.initialize(to: rcl_get_zero_initialized_node())
        let context = UnsafeMutablePointer<rcl_context_t>.allocate(capacity: 1)
        context.initialize(to: rcl_get_zero_initialized_context())
        let options = UnsafeMutablePointer<rcl_node_options_t>.allocate(capacity: 1)
        options.initialize(to: rcl_node_get_default_options())
        rcl_node_init(self.rcl_node, name, namespace, context, options)
    }
}
