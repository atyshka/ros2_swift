import Crcl

class Node {
    var rcl_node: UnsafeMutablePointer<rcl_node_t>
    init(name: String, namespace: String) {
        self.rcl_node.initialize(to: rcl_get_zero_initialized_node())
        rcl_node_init(self.rcl_node, name, namespace, value, value)
    }
}
