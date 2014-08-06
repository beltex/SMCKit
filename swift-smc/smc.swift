import IOKit

class SMC {
    
    init() {
        self.conn = 0
    }
    
    enum TEMPS : String {
        case CPU = "TN0P"
        case GPU = "TC0P"
    }
    
    enum FANS : String {
        case CPU = "TN0P"
        case GPU = "TC0P"
    }
    
    private var conn    :  io_connect_t
    private let IOSERVICE_SMC = "AppleSMC"
    
    private enum SELECTORS : UInt8 {
        case kSMCUserClientOpen  = 0
        case kSMCUserClientClose = 1
        case kSMCHandleYPCEvent  = 2  // READ SELECTOR
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyCount     = 7
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    };
    
    
    func getTemp(key : TEMPS) -> Double {
        return 0.0
    }
    
    func getFanRPM(key : FANS) -> Int {
        return 0
    }
    
    func setFanRPM(key : FANS, RPM : Int) -> Bool {
        return true
    }
    
    
    func openSMC() -> kern_return_t {
        var result  :  kern_return_t
        var service :  io_service_t
        self.conn = 0     // Must init it
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching(IOSERVICE_SMC).takeUnretainedValue())
        
        if (service == 0) {
            println("\(IOSERVICE_SMC) NOT FOUND")
            return -1
        }
        
        result = IOServiceOpen(service, mach_task_self_, 0, &conn)
        IOObjectRelease(service)
        
        if (result != kIOReturnSuccess) {
            println("FAILED TO OPEN IOService; \(result)")
            return -1
        }

        return result
    }
    
    func closeSMC() -> kern_return_t {
        if (IOServiceClose(conn) != kIOReturnSuccess) {
            println("ERROR ON CLOSE")
        }
        
        return kIOReturnSuccess
    }
}
