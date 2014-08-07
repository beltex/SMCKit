import IOKit

public class SMC {
    
    ////////////////////////////////////////////////////////////////////////////
    // PUBLIC ENUMS
    ////////////////////////////////////////////////////////////////////////////
    
    public enum TEMPS : String {
        case CPU = "TN0P"
        case GPU = "TC0P"
    }
    
    public enum FANS : String {
        case CPU = "TN0P"
        case GPU = "TC0P"
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE ENUMS
    ////////////////////////////////////////////////////////////////////////////
    
    private enum SELECTORS : UInt32 {
        case kSMCUserClientOpen  = 0
        case kSMCUserClientClose = 1
        case kSMCHandleYPCEvent  = 2  // READ SELECTOR
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyCount     = 7
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    };
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE STRUCTS
    ////////////////////////////////////////////////////////////////////////////
    
    private struct SMCVersion {
        var major    : CUnsignedChar = 0
        var minor    : CUnsignedChar = 0
        var build    : CUnsignedChar = 0
        var reserved : CUnsignedChar = 0
        var release  : CUnsignedShort = 0
    }
    
    private struct SMCPLimitData {
        var version   : UInt16 = 0
        var length    : UInt16 = 0
        var cpuPLimit : UInt32 = 0
        var gpuPLimit : UInt32 = 0
        var memPLimit : UInt32 = 0
    }
    
    private struct SMCKeyInfoData {
        var dataSize       : IOByteCount = 0
        var dataType       : UInt32 = 0
        var dataAttributes : UInt8 = 0
    }
    
    private struct SMCParamStruct {
        var key        : UInt32 = 0
        var vers       : SMCVersion = SMCVersion()
        var pLimitData : SMCPLimitData = SMCPLimitData()
        var keyInfo    : SMCKeyInfoData = SMCKeyInfoData()
        var padding    : UInt16 = 0     // padding ignore on the C side
        var result     : UInt8 = 0
        var status     : UInt8 = 0
        var data8      : UInt8 = 0
        var data32     : UInt32 = 0
        
        // HACK ALERT: Can't read C array, so instead we enumerate it :)
        
        var bytes_0    : UInt8 = 0
        var bytes_1    : UInt8 = 0
        var bytes_2    : UInt8 = 0
        var bytes_3    : UInt8 = 0
        var bytes_4    : UInt8 = 0
        var bytes_5    : UInt8 = 0
        var bytes_6    : UInt8 = 0
        var bytes_7    : UInt8 = 0
        var bytes_8    : UInt8 = 0
        var bytes_9    : UInt8 = 0
        var bytes_10   : UInt8 = 0
        var bytes_11   : UInt8 = 0
        var bytes_12   : UInt8 = 0
        var bytes_13   : UInt8 = 0
        var bytes_14   : UInt8 = 0
        var bytes_15   : UInt8 = 0
        var bytes_16   : UInt8 = 0
        var bytes_17   : UInt8 = 0
        var bytes_18   : UInt8 = 0
        var bytes_19   : UInt8 = 0
        var bytes_20   : UInt8 = 0
        var bytes_21   : UInt8 = 0
        var bytes_22   : UInt8 = 0
        var bytes_23   : UInt8 = 0
        var bytes_24   : UInt8 = 0
        var bytes_25   : UInt8 = 0
        var bytes_26   : UInt8 = 0
        var bytes_27   : UInt8 = 0
        var bytes_28   : UInt8 = 0
        var bytes_29   : UInt8 = 0
        var bytes_30   : UInt8 = 0
        var bytes_31   : UInt8 = 0
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE ATTRIBUTES
    ////////////////////////////////////////////////////////////////////////////
    
    private var conn : io_connect_t = 0
    private let IOSERVICE_SMC = "AppleSMC"
    
    ////////////////////////////////////////////////////////////////////////////
    // PUBLIC METHODS
    ////////////////////////////////////////////////////////////////////////////
    
    // External param name?
    
    func getTemp(key : TEMPS) -> Double {
        var data = readSMC(key.toRaw())

        return Double(((UInt(data[0]) * UInt(256) + UInt(data[1])) >> UInt(2))) / 64.0
    }
    
    func getFanRPM(key : FANS) -> Int {
        return 0
    }
    
    func setFanRPM(key : FANS, RPM : Int) -> Bool {
        return true
    }
    
    func openSMC() -> kern_return_t {
        var result  : kern_return_t
        var service : io_service_t
        
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
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE METHODS
    ////////////////////////////////////////////////////////////////////////////
    
    private func readSMC(key : String) -> [UInt8] {
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        var data         = [UInt8](count: 32, repeatedValue: 0)
        
        inputStruct.key = 1413689412 // key
        inputStruct.data8 = UInt8(SELECTORS.kSMCGetKeyInfo.toRaw())
        
        callSMC(&inputStruct, outputStruct : &outputStruct)
        
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(SELECTORS.kSMCReadKey.toRaw())
        
        callSMC(&inputStruct, outputStruct : &outputStruct)
        
        data[0] = outputStruct.bytes_0
        data[1] = outputStruct.bytes_1
        
        return data
    }
    
    private func writeSMC() {
        
    }
    
    private func callSMC(inout inputStruct  : SMCParamStruct,
                         inout outputStruct : SMCParamStruct) {
        var result          : kern_return_t
        var inputStructCnt  : size_t = UInt(sizeof(SMCParamStruct))
        var outputStructCnt : size_t = UInt(sizeof(SMCParamStruct))
        
        result = IOConnectCallStructMethod(conn,
                                           SELECTORS.kSMCHandleYPCEvent.toRaw(),
                                           &inputStruct,
                                           inputStructCnt,
                                           &outputStruct,
                                           &outputStructCnt)
        
        if (result != kIOReturnSuccess) {
            println("ERROR")
            
            // TODO: proper mach error conversion
            println((result>>26)&0x3f)
            println((result>>14)&0xfff)
            println(result & 0x3fff)
        }
    }
}
