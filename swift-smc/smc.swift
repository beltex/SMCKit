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
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    SMC keys for temperature sensors - 4 byte multi-character constants

    Not applicable to all Mac's of course. In adition, the definition of the 
    codes may not be 100% accurate necessarily. Finally, list is incomplete.

    Presumed letter translations:
    
    - T = Temperature (if first char)
    - C = CPU
    - G = GPU
    - P = Proximity
    - D = Diode
    - H = Heatsink


    Sources:
    
    - iStat Pro
    - https://github.com/hholtmann/smcFanControl
    - https://github.com/jedda/OSX-Monitoring-Tools
    - http://www.parhelia.ch/blog/statics/k3_keys.html
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
    
    Number of fans on Macs vary of course, thus not all keys will be applicable.
    
    Presumed letter translations:
    
    - F  = Fan
    - Ac = Acutal
    - Mn = Min
    - Mx = Max
    
    Sources: See TMP enum
    */
    public enum FAN : String {
        case FAN_0         = "F0Ac"
        case FAN_0_MIN_RPM = "F0Mn"
        case FAN_0_MAX_RPM = "F0Mx"
        case FAN_1         = "F1Ac"
        case FAN_1_MIN_RPM = "F1Mn"
        case FAN_1_MAX_RPM = "F1Mx"
        case FAN_2         = "F2Ac"
        case FAN_2_MIN_RPM = "F2Mn"
        case FAN_2_MAX_RPM = "F2Mx"
        case NUM_FANS      = "FNum"
    }
    
    
    /**
    IOKit Error Codes - as defined in IOReturn.h

    These are only available to kernel space IOKit code (except for
    kIOReturnSuccess), thus we have to manually import them here. Most of these
    are not revleant to us, but for the sake of completeness.
    
    See "Accessing Hardware From Applications -> Handling Errors" Apple doc for
    more information.
    */
    public enum IOReturn : kern_return_t {
        case kIOReturnSuccess          = 0      // KERN_SUCCESS - OK
        case kIOReturnError            = 0x2bc  // General error
        case kIOReturnNoMemory         = 0x2bd  // Can't allocate memory
        case kIOReturnNoResources      = 0x2be  // Resource shortage
        case kIOReturnIPCError         = 0x2bf  // Error during IPC
        case kIOReturnNoDevice         = 0x2c0  // No such device
        case kIOReturnNotPrivileged    = 0x2c1  // Privilege violation
        case kIOReturnBadArgument      = 0x2c2  // Invalid argument
        case kIOReturnLockedRead       = 0x2c3  // Device read locked
        case kIOReturnExclusiveAccess  = 0x2c5  // Exclusive access and device
                                                // already open
        case kIOReturnBadMessageID     = 0x2c6  // Sent/received messages had
                                                // different msg_id
        case kIOReturnUnsupported      = 0x2c7  // Unsupported function
        case kIOReturnVMError          = 0x2c8  // Misc. VM failure
        case kIOReturnInternalError    = 0x2c9  // Internal error
        case kIOReturnIOError          = 0x2ca  // General I/O error
        case kIOReturnQM1Error         = 0x2cb  // ??? - kIOReturn???Error
        case kIOReturnCannotLock       = 0x2cc  // Can't acquire lock
        case kIOReturnNotOpen          = 0x2cd  // Device not open
        case kIOReturnNotReadable      = 0x2ce  // Read not supported
        case kIOReturnNotWritable      = 0x2cf  // Write not supported
        case kIOReturnNotAligned       = 0x2d0  // Alignment error
        case kIOReturnBadMedia         = 0x2d1  // Media Error
        case kIOReturnStillOpen        = 0x2d2  // Device(s) still open
        case kIOReturnRLDError         = 0x2d3  // RLD failure
        case kIOReturnDMAError         = 0x2d4  // DMA failure
        case kIOReturnBusy             = 0x2d5  // Device Busy
        case kIOReturnTimeout          = 0x2d6  // I/O Timeout
        case kIOReturnOffline          = 0x2d7  // Device offline
        case kIOReturnNotReady         = 0x2d8  // Not ready
        case kIOReturnNotAttached      = 0x2d9  // Device not attached
        case kIOReturnNoChannels       = 0x2da  // No DMA channels left
        case kIOReturnNoSpace          = 0x2db  // No space for data
        case kIOReturnQM2Error         = 0x2dc  // ??? - kIOReturn???Error
        case kIOReturnPortExists       = 0x2dd  // Port already exists
        case kIOReturnCannotWire       = 0x2de  // Can't wire down physical
                                                // memory
        case kIOReturnNoInterrupt      = 0x2df  // No interrupt attached
        case kIOReturnNoFrames         = 0x2e0  // No DMA frames enqueued
        case kIOReturnMessageTooLarge  = 0x2e1  // Oversized msg received on
                                                // interrupt port
        case kIOReturnNotPermitted     = 0x2e2  // Not permitted
        case kIOReturnNoPower          = 0x2e3  // No power to device
        case kIOReturnNoMedia          = 0x2e4  // Media not present
        case kIOReturnUnformattedMedia = 0x2e5  // media not formatted
        case kIOReturnUnsupportedMode  = 0x2e6  // No such mode
        case kIOReturnUnderrun         = 0x2e7  // Data underrun
        case kIOReturnOverrun          = 0x2e8  // Data overrun
        case kIOReturnDeviceError      = 0x2e9  // The device is not working
                                                // properly!
        case kIOReturnNoCompletion     = 0x2ea  // A completion routine is
                                                // required
        case kIOReturnAborted          = 0x2eb  // Operation aborted
        case kIOReturnNoBandwidth      = 0x2ec  // Bus bandwidth would be
                                                // exceeded
        case kIOReturnNotResponding    = 0x2ed  // Device not responding
        case kIOReturnIsoTooOld        = 0x2ee  // Isochronous I/O request for
                                                // distant past!
        case kIOReturnIsoTooNew        = 0x2ef  // Isochronous I/O request for
                                                // distant future
        case kIOReturnNotFound         = 0x2f0  // Data was not found
        case kIOReturnInvalid          = 0x1    // Should never be seen
    }

    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    These are SMC specific return codes
    */
    public enum kSMC : UInt8 {
        case kSMCSuccess     = 0
        case kSMCError       = 1
        case kSMCKeyNotFound = 0x84
    };
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    Method selectors
    */
    private enum Selector : UInt32 {
        case kSMCUserClientOpen  = 0
        case kSMCUserClientClose = 1
        case kSMCHandleYPCEvent  = 2
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyCount     = 7
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    };
    

    //--------------------------------------------------------------------------
    // MARK: PRIVATE STRUCTS
    //--------------------------------------------------------------------------
    
    
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
        var dataSize       : IOByteCount = 0
        var dataType       : UInt32      = 0
        var dataAttributes : UInt8       = 0
    }
    
    
    /**
    Defined by AppleSMC.kext.
    
    This is the predefined struct that must be passed to communicate with the
    AppleSMC driver. While the driver is closed source, the definition of this
    struct happened to appear in the Apple PowerManagement project at around
    version 211, and soon after disappeared. It can be seen in the PrivateLib.c
    file under pmconfigd. Given that it is C code, this is the closest
    translation to Swift from a type perspective.
    
    ISSUES
    
    - Padding for struct alignment when passed over to C side
    - Can't read array once passed back from C, thus enumerate 32 UInt8 values
      instead
    - Size of struct must be 80 bytes
    
    https://www.opensource.apple.com/source/PowerManagement/PowerManagement-211/
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
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ATTRIBUTES
    //--------------------------------------------------------------------------
    
    
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
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Open a connection to the SMC
    
    :returns: kIOReturnSuccess on successful connection to the SMC.
    */
    public func openSMC() -> kern_return_t {
        var result  : kern_return_t
        var service : io_service_t
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                  IOServiceMatching(IOSERVICE_SMC).takeUnretainedValue())
        
        if (service == 0) {
            // NOTE: IOServiceMatching documents 0 on failure
            
            println("\(IOSERVICE_SMC) NOT FOUND")
            return IOReturn.kIOReturnError.toRaw()
        }
        
        result = IOServiceOpen(service, mach_task_self_, 0, &conn)
        IOObjectRelease(service)
        
        return result
    }
    
    
    /**
    Close connection to the SMC
    
    :returns: kIOReturnSuccess on successful close of connection to the SMC.
    */
    public func closeSMC() -> kern_return_t {
        return IOServiceClose(conn)
    }
    
    
    /**
    Check if an SMC key is valid. Useful for determining if a certain machine
    has particular sensor or fan for example.
    
    :returns: The SMC return code. See kSMC enum.
    */
    public func isKeyValid(key : String) -> UInt8 {
        // TODO: Should this return the result kern_return_t as well?
    
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.toRaw())
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
                                                
        return outputStruct.result
    }
    
    
    /**
    Get the current temperature from a sensor
    
    :param: key The temperature sensor to read from
    :returns: Temperature in Celsius. If the sensor is not found, or an error
              occurs, return will be zero
    */
    public func getTemp(key : TMP) -> (UInt, kern_return_t, UInt8) {
       var result = readSMC(key.toRaw())
        
       // We drop the decimal value (data[1]) for now - thus maybe be off +/- 1
       // Data type is sp78 - unsigned floating point
       // http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
       return (UInt(result.data[0]), result.IOReturn, result.kSMC)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - FANS
    //--------------------------------------------------------------------------
    
    
    /**
    Get the current speed (RPM - revolutions per minute) of a fan
    
    :param: key The fan to check
    :returns: The fan RPM. If the fan is not found, or an error occurs, return
              will be zero
    */
    public func getFanRPM(num : UInt) -> (UInt, kern_return_t) {
        return fanCall("F" + String(num) + "Ac")
    }
    
    
    public func getFanMinRPM(num : UInt) -> (UInt, kern_return_t) {
        return fanCall("F" + String(num) + "Mn")
    }
    
    
    public func getFanMaxRPM(num : UInt) -> (UInt, kern_return_t) {
        return fanCall("F" + String(num) + "Mx")
    }
    
    
    /**
    Get the number of fans on this machine

    :returns: The number of fans and the kernel return value
    */
    public func getNumFans() -> (UInt, kern_return_t, UInt8) {
        var result = readSMC(FAN.NUM_FANS.toRaw())
        
        return (UInt(result.data[0]), result.IOReturn, result.kSMC)
    }
    
    
    /**
    Set the speed (RPM - revolutions per minute) of a fan

    NOTE: You are playing with hardware here, BE CAREFUL.

    :param: key The fan to set
    :param: rpm The speed you would like to set the fan to.
    :returns: True if successful, false otherwise.
    */
    public func setFanRPM(num : UInt, rpm : UInt) -> kern_return_t {
        var min = getFanMinRPM(num)
        var max = getFanMaxRPM(num)
        
        // Safety check: rpm must be within acceptable range of fan speed
        if (min.1 == kIOReturnSuccess && max.1 == kIOReturnSuccess) {
            
            //&& rpm >= min.0 && rpm <= max.0) {
            // now call write
            
            var data = [UInt8](count: 32, repeatedValue: 0)
            data[0] = UInt8(rpm >> 6)
            data[1] = UInt8((rpm << 2) ^ (UInt(data[0]) << 8))
                               
            return writeSMC("F" + String(num) + "Mn", data: data)
        }
        else {
            println("Unsafe fan RPM")
            return IOReturn.kIOReturnBadArgument.toRaw()
        }
    }
    

    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------

    
    private func fanCall(key : String) -> (UInt, kern_return_t) {
        // Data type for fan calls - fpe2
        // This is assumend to mean floating point, with 2 exponent bits
        // http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
        var result = readSMC(key)
        var ans : UInt = 0
        var data = result.data
        
        ans += UInt(data[0]) << 6
        ans += UInt(data[1]) >> 2
        
        return (ans, result.IOReturn)
    }
    
    
    /**
    Read data from the SMC
    
    :param: key The SMC key
    :returns: Array of 32 UInt8 vals, the raw data return from the SMC
    */
    private func readSMC(key : String) -> (data     : [UInt8],
                                           IOReturn : kern_return_t,
                                           kSMC     : UInt8) {
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        var data         = [UInt8](count: 32, repeatedValue: 0)
        
        // First call to AppleSMC - get key info
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.toRaw())
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        if (result != kIOReturnSuccess ||
            outputStruct.result != kSMC.kSMCSuccess.toRaw()) {
            return (data, result, outputStruct.result)
        }
        
        // Second call to AppleSMC - now we can get the data
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(Selector.kSMCReadKey.toRaw())
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        if (result != kIOReturnSuccess ||
            outputStruct.result != kSMC.kSMCSuccess.toRaw()) {
            return (data, result, outputStruct.result)
        }
        
        // Set the data
        data[0]  = outputStruct.bytes_0
        data[1]  = outputStruct.bytes_1
        data[2]  = outputStruct.bytes_2
        data[3]  = outputStruct.bytes_3
        data[4]  = outputStruct.bytes_4
        data[5]  = outputStruct.bytes_5
        data[6]  = outputStruct.bytes_6
        data[7]  = outputStruct.bytes_7
        data[8]  = outputStruct.bytes_8
        data[9]  = outputStruct.bytes_9
        data[10] = outputStruct.bytes_10
        data[11] = outputStruct.bytes_11
        data[12] = outputStruct.bytes_12
        data[13] = outputStruct.bytes_13
        data[14] = outputStruct.bytes_14
        data[15] = outputStruct.bytes_15
        data[16] = outputStruct.bytes_16
        data[17] = outputStruct.bytes_17
        data[18] = outputStruct.bytes_18
        data[19] = outputStruct.bytes_19
        data[20] = outputStruct.bytes_20
        data[21] = outputStruct.bytes_21
        data[22] = outputStruct.bytes_22
        data[23] = outputStruct.bytes_23
        data[24] = outputStruct.bytes_24
        data[25] = outputStruct.bytes_25
        data[26] = outputStruct.bytes_26
        data[27] = outputStruct.bytes_27
        data[28] = outputStruct.bytes_28
        data[29] = outputStruct.bytes_29
        data[30] = outputStruct.bytes_30
        data[31] = outputStruct.bytes_31
        
        return (data, result, outputStruct.result)
    }
    
    
    /**
    Write data to the SMC
    
    :returns:
    */
    private func writeSMC(key : String, data : [UInt8]) -> kern_return_t {
        // FIXME: Implement this
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        
        // First call to AppleSMC - get key info
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.toRaw())
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        if (result != kIOReturnSuccess) {
            return result
        }
        
        
        // Second call to AppleSMC - now we can get the data
        
        // TODO: Check that dataSize is the same as given from user
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(Selector.kSMCWriteKey.toRaw())
        
        inputStruct.bytes_0 = data[0]
        inputStruct.bytes_1 = data[1]
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        println(outputStruct.result)
        println(outputStruct.bytes_0)
        if (result != kIOReturnSuccess) {
            return result
        }
        
        return result
    }
    
    
    /**
    Make a call to the SMC
    
    :param: inputStruct Struct that holds data telling the SMC what you want
    :param: outputStruct Struct holding the SMC's response
    :returns:
    */
    private func callSMC(inout inputStruct  : SMCParamStruct,
                         inout outputStruct : SMCParamStruct) -> kern_return_t {
        var result : kern_return_t
        
        // When the structs are cast to SMCParamStruct on the C side (AppleSMC)
        // there expected to be 80 bytes. This may not be the case on the Swift
        // side. One hack is to simply hardcode this to 80.
        var inputStructCnt  : size_t = UInt(sizeof(SMCParamStruct))
        var outputStructCnt : size_t = UInt(sizeof(SMCParamStruct))
                            
        if (inputStructCnt != 80) {
            // Houston, we have a problem. Depending how far off this is from
            // 80, call may or may not work.
            return IOReturn.kIOReturnBadArgument.toRaw()
        }
        
        result = IOConnectCallStructMethod(conn,
                                           Selector.kSMCHandleYPCEvent.toRaw(),
                                           &inputStruct,
                                           inputStructCnt,
                                           &outputStruct,
                                           &outputStructCnt)
        
        if (result != kIOReturnSuccess) {
            // Determine the exact error
            result = getErrorCode(result)
        }

        return result
    }
    

    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS
    //--------------------------------------------------------------------------

    
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
    
    :param: err The raw error code
    :returns: The IOReturn error code. If not found, returns the original error.
    */
    private func getErrorCode(err : kern_return_t) -> kern_return_t {
        var lookup : kern_return_t? = IOReturn.fromRaw(err & 0x3fff)?.toRaw()
        
        return (lookup ?? err)
    }
}
