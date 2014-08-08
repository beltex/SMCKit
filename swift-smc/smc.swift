/*
 * {description}
 *
 * Copyright (C) 2014  beltex <https://github.com/beltex>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import IOKit

public class SMC {
    
    ////////////////////////////////////////////////////////////////////////////
    // PUBLIC ENUMS
    ////////////////////////////////////////////////////////////////////////////
    
    public enum TMP : String {
        // T: Temperature
        // C: CPU
        // G: GPU
        // P: Proximity
        // D: Diode
        //
        
        case AMBIENT_AIR_0          = "TA0P"
        case AMBIENT_AIR_1          = "TA1P"
        case CPU_0_DIODE            = "TC0D"
        case CPU_0_HEATSINK         = "TC0H"
        case CPU_0_PROXIMITY        = "TC0P"
        case ENCLOSURE_BASE_0       = "TB0T"
        case ENCLOSURE_BASE_1       = "TB1T"
        case ENCLOSURE_BASE_2       = "TB2T"
        case ENCLOSURE_BASE_3       = "TB3T"
        case GPU_0_DIODE            = "TG0D"
        case GPU_0_HEATSINK         = "TG0H"
        case GPU_0_PROXIMITY        = "TG0P"
        case HARD_DRIVE_BAY         = "TH0P"
        case MEMORY_SLOT_0          = "TM0S"
        case MEMORY_SLOTS_PROXIMITY = "TM0P"
        case NORTHBRIDGE            = "TN0H"
        case NORTHBRIDGE_DIODE      = "TN0D"
        case NORTHBRIDGE_PROXIMITY  = "TN0P"
        case THUNDERBOLT_0          = "TI0P"
        case THUNDERBOLT_1          = "TI1P"
        case WIRELESS_MODULE        = "TW0P"
    }
    
    public enum FAN : String {
        case FAN_0 = "F0Ac"
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE ENUMS
    ////////////////////////////////////////////////////////////////////////////
    
    private enum SELECTOR : UInt32 {
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
        var dataSize       : IOByteCount = 0    // how many vals in the array
        var dataType       : UInt32 = 0
        var dataAttributes : UInt8 = 0
    }
    
    private struct SMCParamStruct {
        var key        : UInt32 = 0
        var vers       : SMCVersion     = SMCVersion()
        var pLimitData : SMCPLimitData  = SMCPLimitData()
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
    
    func getTemp(key : TMP) -> Double {
        var data = readSMC(key.toRaw())
        var temp : Double = Double(((UInt(data[0]) * UInt(256) + UInt(data[1])) >> UInt(2))) / 64.0
        
        return ceil(temp)
    }
    
    func getFanRPM(key : FAN) -> Double {
        // fpe2
        
        var data = readSMC(key.toRaw())
        
        println(data)
        
//        var ans = 0
//        ans += Int(data[0]) << (2 - 1 - 0) * (8 - 2);
//        ans += (Int(data[1]) & 0xff) >> 2;
//        
//        var t = (Int(data[1]) & 0x03)
        
//        (data[0] << UInt8(6)) + ((data[1] & 0xff) >> 2) + ((data[1] & UInt8(0x03)) * 0.25)
        
        return 0.0
        
//        var total :UInt8 = 0
//        var size = 2
//        var e : UInt8 = 2
//        
//        for var i = 0; i < size ; i++ {
//            if (i == (size - 1)) {
//                total += (data[i] & 0xff) >> e
//            }
//            else {
//                total += data[i] << (size - 1 - i) * (8 - e)
//            }
//        }
        
//        
//        
//        return Double(total) + (Double((Int(data[size-1]) & 0x03)) * 0.25)
    }
    
    func setFanRPM(key : FAN, RPM : Int) -> Bool {
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
        
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(SELECTOR.kSMCGetKeyInfo.toRaw())
        
        callSMC(&inputStruct, outputStruct : &outputStruct)
        
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(SELECTOR.kSMCReadKey.toRaw())
        
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
                                           SELECTOR.kSMCHandleYPCEvent.toRaw(),
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
    
    ////////////////////////////////////////////////////////////////////////////
    // PRIVATE METHODS - HELPERS
    ////////////////////////////////////////////////////////////////////////////
    
    private func toUInt32(key : String) -> UInt32 {
        var ans   : Int32 = 0
        var shift : Int32 = 24

        for char in key.utf8 {
            ans += (Int32(char) << shift)
            shift -= 8
        }
        
        return UInt32(ans).littleEndian
    }
    
    private func toString(key : UInt32) -> String {
        var ans = String()
        var shift : Int32 = 24

        for var index = 0; index < 4; ++index {
            ans += Character(UnicodeScalar(UInt32(Int32(key) >> shift)))
            shift -= 8
        }
        
        return ans
    }
}
