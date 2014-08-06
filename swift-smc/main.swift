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
    //return -1
}

result = IOServiceOpen(service, mach_task_self_, 0, &conn)
IOObjectRelease(service)

if (result != kIOReturnSuccess) {
    println("FAILED TO OPEN IOService; \(result)")
    //return -1
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
    //    println("BTYE ARRAY CHECK: \(input.bytes[0])")
}
else {
    println("///////////////////////////")
    println("NOOO")
    println((r2>>26)&0x3f)
    println((r2>>14)&0xfff)
    println(r2 & 0x3fff)
}


var dataSize = output.keyInfo.dataSize

input  = SMCParamStruct()
output = SMCParamStruct()
input.key = 1413689412
input.keyInfo.dataSize = dataSize
input.data8 = 5


// Overwritten - first one is, second is to denote size of struct returned from AppleSMC
inputStructCnt = 80
outputStructCnt = 80

var ans = [UInt8](count: 32, repeatedValue: 0)

r2 = IOConnectCallStructMethod(conn, 2, &input, inputStructCnt, &output, &outputStructCnt)


if (r2 == kIOReturnSuccess) {
    println("WORKS")
    //    println("TEMP: \(output.bytes)")
    //    println("SIZEOF VALUE \(sizeofValue(output.bytes))")
    //    r2 = IOConnectCallStructMethodWrapper(conn, 2, &input, inputStructCnt, &output, &outputStructCnt)
    //    println("WORKS")
    //    var p = UnsafeBufferPointer(start: &output.btyes, length: 32)
    
    
    //    memcpy(&ans, output.btyes, 32)
    //    var test = UnsafeBufferPointer(start: &output.btyes, length: 32)
    var intVal = Int(output.bytes_0) * Int(256) + Int(output.bytes_1)
    println("TEMP: \(Double(intVal / 4) / 64.0)")
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