import Crcl

class Publisher {
    private var rcl_pub_ptr: UnsafeMutablePointer<rcl_publisher_t>

    init(topic: String) {
        self.rcl_pub_ptr = UnsafeMutablePointer<rcl_publisher_t>.allocate(capacity: 1)
        self.rcl_pub_ptr.initialize(to: rcl_get_zero_initialized_publisher())
        var node_ptr: UnsafeMutablePointer<rcl_node_t> = UnsafeMutablePointer<rcl_node_t>.allocate(capacity: 1)
        node_ptr.initialize(to: rcl_get_zero_initialized_node())
        //rcl_publisher_init(self.rcl_pub_ptr, node_ptr, value, topic, val1ue)
    }
}