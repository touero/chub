import Foundation

func getUsedMemory() -> UInt64? {
    var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
    var vmStat: vm_statistics64 = vm_statistics64_data_t()

    var result = withUnsafeMutablePointer(to: &vmStat) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
        }
    }

    guard result == KERN_SUCCESS else {
        return nil
    }

    var usedMemory = (UInt64(vmStat.active_count) + UInt64(vmStat.inactive_count) + UInt64(vmStat.wire_count)) * UInt64(vm_page_size)

    return usedMemory
}

func check() {
    if let systemUsedMemory = getUsedMemory() {
        var temp = Double(systemUsedMemory) / pow(1024, 3)
        var systemUsedMemoryG = String(format: "%.2f", temp)
        print("already used: \(systemUsedMemoryG)G")
    } else {
        print("error")
    }
}

var counter = 1
let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){
    timer in
    print("==> now is \(counter)")
    check()
    counter += 1
    
    if counter > 60{
        timer.invalidate()
        print("==> finish")
    }
}

RunLoop.main.run()
