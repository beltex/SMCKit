/*
 * smc.swift
 * swift-smc
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

/**
System Management Controller (SMC) API from user space for Intel based Macs.
Works by talking to the AppleSMC.kext (kernel extension), the driver for the
SMC.
*/
public class SMC {
    
    
    // MARK: Public Enums
    
    
    /**
    SMC keys for temperature sensors - 4 byte multi-character constants

    Sourced from various locations (see README). Not applicable to all Mac's of
    course. The actual definition of all the codes is not 100% accurate
    necessarily. List is also incomplete.

    Presumed letter translations
    
    - T = Temperature (if first char)
    - C = CPU
    - G = GPU
    - P = Proximity
    - D = Diode
    - H = Heatsink
    */
    public enum TMP : String {
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
    
    
    /**
    SMC keys for fans - 4 byte multi-character constants
    */
    public enum FAN : String {
        case FAN_0 = "F0Ac"
    }
    
    
    /**
    
    These are only available to kernel space IOKit code, thus we have to manually
    import them here.
    
    See "Accessing Hardware From Applications -> Handling Errors" Apple doc
    */
    public enum IORETURN : kern_return_t {
        case kIOReturnError         = 0x2bc  // General error
        case kIOReturnNoMemory      = 0x2bd  // Can't allocate memory
        case kIOReturnNoResources   = 0x2be  // Resource shortage
        case kIOReturnIPCError      = 0x2bf  // Error during IPC
        case kIOReturnNoDevice      = 0x2c0  // No such device
        case kIOReturnNotPrivileged = 0x2c1  // Privilege violation
        case kIOReturnBadArgument   = 0x2c2  // Invalid argument
        case kIOReturnLockedRead    = 0x2c3  // Device read locked
    }
    
    
    // MARK: Private Enums
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    These are SMC specific, thus we wrap them in mach errors when returning
    to the user
    */
    private enum RESULT : UInt8 {
        case kSMCKeyNotFound = 0x84
        case kSMCSuccess	 = 0
        case kSMCError	     = 1
    };
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    Method selectors
    */
    private enum SELECTOR : UInt32 {
        case kSMCUserClientOpen  = 0
        case kSMCUserClientClose = 1
        case kSMCHandleYPCEvent  = 2
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyCount     = 7
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    };
    

    // MARK: Private Structs
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    */
    private struct SMCVersion {
        var major    : CUnsignedChar  = 0
        var minor    : CUnsignedChar  = 0
        var build    : CUnsignedChar  = 0
        var reserved : CUnsignedChar  = 0
        var release  : CUnsignedShort = 0
    }
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    */
    private struct SMCPLimitData {
        var version   : UInt16 = 0
        var length    : UInt16 = 0
        var cpuPLimit : UInt32 = 0
        var gpuPLimit : UInt32 = 0
        var memPLimit : UInt32 = 0
    }
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    - dataSize : How many values written to SMCParamStruct.bytes
    - dataType : Type of data written to SMCParamStruct.bytes. This lets us
                 know how to interpret it (translate it to human readable)
    */
    private struct SMCKeyInfoData {
        var dataSize       : IOByteCount = 0    // how many vals in the array
        var dataType       : UInt32      = 0
        var dataAttributes : UInt8       = 0
    }
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.

    // TODO: Expliation
    */
    private struct SMCParamStruct {
        var key        : UInt32 = 0
        var vers                = SMCVersion()
        var pLimitData          = SMCPLimitData()
        var keyInfo             = SMCKeyInfoData()
        var padding    : UInt16 = 0
        var result     : UInt8  = 0
        var status     : UInt8  = 0
        var data8      : UInt8  = 0
        var data32     : UInt32 = 0
        var bytes_0    : UInt8  = 0
        var bytes_1    : UInt8  = 0
        var bytes_2    : UInt8  = 0
        var bytes_3    : UInt8  = 0
        var bytes_4    : UInt8  = 0
        var bytes_5    : UInt8  = 0
        var bytes_6    : UInt8  = 0
        var bytes_7    : UInt8  = 0
        var bytes_8    : UInt8  = 0
        var bytes_9    : UInt8  = 0
        var bytes_10   : UInt8  = 0
        var bytes_11   : UInt8  = 0
        var bytes_12   : UInt8  = 0
        var bytes_13   : UInt8  = 0
        var bytes_14   : UInt8  = 0
        var bytes_15   : UInt8  = 0
        var bytes_16   : UInt8  = 0
        var bytes_17   : UInt8  = 0
        var bytes_18   : UInt8  = 0
        var bytes_19   : UInt8  = 0
        var bytes_20   : UInt8  = 0
        var bytes_21   : UInt8  = 0
        var bytes_22   : UInt8  = 0
        var bytes_23   : UInt8  = 0
        var bytes_24   : UInt8  = 0
        var bytes_25   : UInt8  = 0
        var bytes_26   : UInt8  = 0
        var bytes_27   : UInt8  = 0
        var bytes_28   : UInt8  = 0
        var bytes_29   : UInt8  = 0
        var bytes_30   : UInt8  = 0
        var bytes_31   : UInt8  = 0
    }
    
    
    // MARK: Private Attributes
    
    
    /**
    Our connection to the SMC. Must close it when done.
    */
    private var conn : io_connect_t = 0
    
    
    /**
    Name of the SMC IOService as seen in the IORegistry. You can view it either
    via command line with ioreg or through the IORegistryExplorer app (found on
    Apple's developer site - Hardware IO Tools for Xcode)
    */
    private let IOSERVICE_SMC = "AppleSMC"
    
    
    // MARK: Public Methods
    
    
    /**
    Get the current temperature from a sensor
    
    :param: key The temperature sensor to read from
    :returns: Temperature in Celsius. If the sensor is not found, or an error
              occurs, return will be zero
    */
    public func getTemp(key : TMP) -> UInt {
       var data = readSMC(key.toRaw())
        
       // We drop decimal value (data[1]) for now - thus maybe be off +/- 1
       return (UInt(data[0]) * 256) >> 8
    }
    
    
    /**
    Get the current speed (RPM - revolutions per minute) of a fan
    
    :param: key The fan to check
    :returns: The fan RPM. If the fan is not found, or an error occurs, return
             will be zero
    */
    public func getFanRPM(key : FAN) -> UInt {
        var data = readSMC(key.toRaw())
        
        // FIXME: Proper convert of fpe2 data
        return 1
    }
    
    
    /**
    Set the speed (RPM - revolutions per minute) of a fan

    NOTE: You are playing with hardware here, BE CAREFUL.

    :param: key The fan to set
    :param: rpm The speed you would like to set the fan to.
    :returns: True if successful, false otherwise.
    */
    public func setFanRPM(key : FAN, rpm : UInt) -> Bool {
        // FIXME: Implement this
        // TODO: Make sure to have checks that rpm value is with range of fan
        return true
    }
    
    
    /**
    Open a connection to the SMC
    
    :returns:
    */
    public func openSMC() -> kern_return_t {
        var result  : kern_return_t
        var service : io_service_t
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching(IOSERVICE_SMC).takeUnretainedValue())
        
        if (service == 0) {
            return IORETURN.kIOReturnNoDevice.toRaw()
        }
        
        result = IOServiceOpen(service, mach_task_self_, 0, &conn)
        IOObjectRelease(service)
        


        return result
    }
    
    
    /**
    Close connection to the SMC
    
    :returns:
    */
    public func closeSMC() -> kern_return_t {
        return IOServiceClose(conn)
    }
    
    
    /**
    Check if an SMC key is valid. Useful for determining if a certain machine
    has particular sensor or fan for example.
    
    :returns:
    */
    public func isKeyValid(key : String) -> kern_return_t {
        // TODO: Bool or kern_return_t for return type?
        
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(SELECTOR.kSMCGetKeyInfo.toRaw())
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        if (outputStruct.result == RESULT.kSMCKeyNotFound.toRaw()) {
            return IORETURN.kIOReturnNoDevice.toRaw()
        }
        else if (outputStruct.result == RESULT.kSMCError.toRaw()) {
            return IORETURN.kIOReturnError.toRaw()
        }
        
        // TODO: Check the result error code
        // IORETURN.fromRaw(result & 0x3fff)
        
        return result
    }
    

    // MARK: Private Methods

    
    /**
    Read data from the SMC
    
    :param: key The SMC key
    :returns: Array of 32 UInt8 vals, the raw data return from the SMC
    */
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
    
    
    /**
    Write data to the SMC
    
    :returns:
    */
    private func writeSMC() {
        // FIXME: Implement this
    }
    
    
    /**
    Make a call to the SMC
    
    :param: inputStruct Struct that holds data telling the SMC what you want
    :param: outputStruct Struct holding the SMC's response
    :returns:
    */
    private func callSMC(inout inputStruct  : SMCParamStruct,
                         inout outputStruct : SMCParamStruct) -> kern_return_t {
        var result          : kern_return_t
        var inputStructCnt  : size_t = UInt(sizeof(SMCParamStruct))
        var outputStructCnt : size_t = UInt(sizeof(SMCParamStruct))
        
        result = IOConnectCallStructMethod(conn,
                                           SELECTOR.kSMCHandleYPCEvent.toRaw(),
                                           &inputStruct,
                                           inputStructCnt,
                                           &outputStruct,
                                           &outputStructCnt)
                            
        // TODO: Error check result here?

        return result
    }
    

    // MARK: Private Methods - Helpers

    
    /**
    Convert SMC key to UInt32. This must be done to pass it to the SMC.
    
    :param: key The SMC key to convert
    :returns: UInt32 translation of it with little-endian representation
    */
    private func toUInt32(key : String) -> UInt32 {
        var ans   : Int32 = 0
        var shift : Int32 = 24

        for char in key.utf8 {
            ans += (Int32(char) << shift)
            shift -= 8
        }
        
        return UInt32(ans).littleEndian
    }
    
    
    /**
    For converting the dataType return from the SMC to human readable
    */
    private func toString(key : UInt32) -> String {
        // FIXME: This doesn't work correctly
        var ans = String()
        var shift : Int32 = 24

        for var index = 0; index < 4; ++index {
            ans += Character(UnicodeScalar(UInt32(Int32(key) >> shift)))
            shift -= 8
        }
        
        return ans
    }
    
    
    /**
    IOReturn error code lookup
    */
    private func err_get_code(err: kern_return_t) -> kern_return_t? {
        return IORETURN.fromRaw(err & 0x3fff)?.toRaw()
    }
}
