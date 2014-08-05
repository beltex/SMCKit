////////////////////////////////////////////////////////////////////////////////
// IMPORTS
////////////////////////////////////////////////////////////////////////////////


import IOKit


////////////////////////////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////////////////////////////


let IOSERVICE_APPLESMC = "AppleSMC"


////////////////////////////////////////////////////////////////////////////////
// ENUMS
////////////////////////////////////////////////////////////////////////////////


//enum TEMPS : String {
//    case CPU = "TN0P"
//    case GPU = "TC0P"
//}
//
//
//enum SELECTORS : UInt8 {
//    case kSMCUserClientOpen  = 0
//    case kSMCUserClientClose = 1
//    case kSMCHandleYPCEvent  = 2  // READ SELECTOR
//    case kSMCReadKey         = 5
//    case kSMCWriteKey        = 6
//    case kSMCGetKeyCount     = 7
//    case kSMCGetKeyFromIndex = 8
//    case kSMCGetKeyInfo      = 9
//};


////////////////////////////////////////////////////////////////////////////////
// STRUCTS
////////////////////////////////////////////////////////////////////////////////


struct SMCVersion {
    var major    : CUnsignedChar = 0
    var minor    : CUnsignedChar = 0
    var build    : CUnsignedChar = 0
    var reserved : CUnsignedChar = 0
    var release  : CUnsignedShort = 0
}


struct SMCPLimitData {
    var version   : UInt16 = 0
    var length    : UInt16 = 0
    var cpuPLimit : UInt32 = 0
    var gpuPLimit : UInt32 = 0
    var memPLimit : UInt32 = 0
}


struct SMCKeyInfoData {
    var dataSize       : IOByteCount = 0
    var dataType       : UInt32 = 0
    var dataAttributes : UInt8 = 0
}


struct SMCParamStruct {
    var key        : UInt32 = 0
    var vers       : SMCVersion = SMCVersion()
    var pLimitData : SMCPLimitData = SMCPLimitData()
    var keyInfo    : SMCKeyInfoData = SMCKeyInfoData()
    var padding    : UInt16 = 0     // padding ignore on the C side
    var result     : UInt8 = 0
    var status     : UInt8 = 0
    var data8      : UInt8 = 0
    var data32     : UInt32 = 0
    var btyes      = [UInt8](count: 32, repeatedValue: 0)
}


////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////


var result  :  kern_return_t
var service :  io_service_t
var conn    :  io_connect_t = 0     // Must init it

service = IOServiceGetMatchingService(kIOMasterPortDefault,
    IOServiceMatching(IOSERVICE_APPLESMC).takeUnretainedValue())

if (service == 0) {
    println("\(IOSERVICE_APPLESMC) NOT FOUND")
}

result = IOServiceOpen(service, mach_task_self_, 0, &conn)
IOObjectRelease(service)

if (result != kIOReturnSuccess) {
    println("FAILED TO OPEN IOService; \(result)")
}

var r2 : kern_return_t

var input  = SMCParamStruct()
var output = SMCParamStruct()
var inputStructCnt:size_t = 80
var outputStructCnt:size_t = 80


println("SWIFT STRUCT SIZEOF: \(sizeof(SMCParamStruct))")
input.key = 1413689412
input.data8 = 9


println("SWIFT DATA8: \(input.data8)")

r2 = IOConnectCallStructMethod(conn, 2, &input, inputStructCnt, &output, &outputStructCnt)


if (r2 == kIOReturnSuccess) {
    println("WORKS")
}
else {
    println("///////////////////////////")
    println("NOOO")
    println((r2>>26)&0x3f)
    println((r2>>14)&0xfff)
    println(r2 & 0x3fff)
}

if (IOServiceClose(conn) != kIOReturnSuccess) {
    println("ERROR ON CLOSE")
}