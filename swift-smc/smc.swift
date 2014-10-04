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
import Foundation

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
    
    - http://www.opensource.apple.com/source/net_snmp/
    - https://www.apple.com/downloads/dashboard/status/istatpro.html
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
        case HDD_PROXIMITY          = "TH0P"
        case HEATSINK_0             = "Th0H"
        case HEATSINK_1             = "Th1H"
        case HEATSINK_2             = "Th2H"
        case LCD_PROXIMITY          = "TL0P"
        case MEM_SLOT_0             = "TM0S"
        case MEM_SLOTS_PROXIMITY    = "TM0P"
        case MISC_PROXIMITY         = "Tm0P"
        case NORTHBRIDGE            = "TN0H"
        case NORTHBRIDGE_DIODE      = "TN0D"
        case NORTHBRIDGE_PROXIMITY  = "TN0P"
        case ODD_PROXIMITY          = "TO0P"
        case PWR_SUPPLY_PROXIMITY   = "Tp0P"
        case THUNDERBOLT_0          = "TI0P"
        case THUNDERBOLT_1          = "TI1P"
        case WIRELESS_MODULE        = "TW0P"
        
        
        /**
        For enumerating all values of the enum. Not ideal. Seems to be the
        cleanest current solution. See: http://stackoverflow.com/a/24137319
        */
        static let allValues = ["AMBIENT_AIR_0"         : AMBIENT_AIR_0,
                                "AMBIENT_AIR_1"         : AMBIENT_AIR_1,
                                "CPU_0_DIODE"           : CPU_0_DIODE,
                                "CPU_0_HEATSINK"        : CPU_0_HEATSINK,
                                "CPU_0_PROXIMITY"       : CPU_0_PROXIMITY,
                                "ENCLOSURE_BASE_0"      : ENCLOSURE_BASE_0,
                                "ENCLOSURE_BASE_1"      : ENCLOSURE_BASE_1,
                                "ENCLOSURE_BASE_2"      : ENCLOSURE_BASE_2,
                                "ENCLOSURE_BASE_3"      : ENCLOSURE_BASE_3,
                                "GPU_0_DIODE"           : GPU_0_DIODE,
                                "GPU_0_HEATSINK"        : GPU_0_HEATSINK,
                                "GPU_0_PROXIMITY"       : GPU_0_PROXIMITY,
                                "HDD_PROXIMITY"         : HDD_PROXIMITY,
                                "HEATSINK_0"            : HEATSINK_0,
                                "HEATSINK_1"            : HEATSINK_1,
                                "HEATSINK_2"            : HEATSINK_2,
                                "LCD_PROXIMITY"         : LCD_PROXIMITY,
                                "MEM_SLOT_0"            : MEM_SLOT_0,
                                "MEM_SLOTS_PROXIMITY"   : MEM_SLOTS_PROXIMITY,
                                "MISC_PROXIMITY"        : MISC_PROXIMITY,
                                "NORTHBRIDGE"           : NORTHBRIDGE,
                                "NORTHBRIDGE_DIODE"     : NORTHBRIDGE_DIODE,
                                "NORTHBRIDGE_PROXIMITY" : NORTHBRIDGE_PROXIMITY,
                                "ODD_PROXIMITY"         : ODD_PROXIMITY,
                                "PWR_SUPPLY_PROXIMITY"  : PWR_SUPPLY_PROXIMITY,
                                "THUNDERBOLT_0"         : THUNDERBOLT_0,
                                "THUNDERBOLT_1"         : THUNDERBOLT_1,
                                "WIRELESS_MODULE"       : WIRELESS_MODULE]
    }
    
    
    /**
    SMC keys for fans - 4 byte multi-character constants
    
    Number of fans on Macs vary of course, thus not all keys will be applicable.
    
    Presumed letter translations:
    
    - F  = Fan
    - Ac = Acutal
    - Mn = Min
    - Mx = Max
    - Sf = Safe
    - Tg = Target
    
    Sources: See TMP enum
    */
    public enum FAN : String {
        case FAN_0            = "F0Ac"
        case FAN_0_DESC       = "F0ID"
        case FAN_0_MIN_RPM    = "F0Mn"
        case FAN_0_MAX_RPM    = "F0Mx"
        case FAN_0_SAFE_RPM   = "F0Sf"
        case FAN_0_TARGET_RPM = "F0Tg"
        case FAN_1            = "F1Ac"
        case FAN_1_MIN_RPM    = "F1Mn"
        case FAN_1_MAX_RPM    = "F1Mx"
        case FAN_1_SAFE_RPM   = "F1Sf"
        case FAN_1_TARGET_RPM = "F1Tg"
        case FAN_2            = "F2Ac"
        case FAN_2_MIN_RPM    = "F2Mn"
        case FAN_2_MAX_RPM    = "F2Mx"
        case FAN_2_SAFE_RPM   = "F2Sf"
        case FAN_2_TARGET_RPM = "F2Tg"
        case NUM_FANS         = "FNum"
        case FORCE_BITS       = "FS! "
    }
    
    
    /**
    Misc SMC keys - 4 byte multi-character constants
    
    Sources: See TMP enum
    */
    public enum SMC_KEY : String {
        case BATT_PWR = "BATP"
        case NUM_KEYS = "#KEY"
        case ODD_FULL = "MSDI"
    }
    
    
    /**
    SMC data types - 4 byte multi-character constants
    
    Sources: See TMP enum
    
    http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
    */
    public enum DataType : String {
        case FLAG = "flag"
        case FPE2 = "fpe2"
        case SFDS = "{fds"
        case SP78 = "sp78"
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
    }
    
    
    /**
    Temperature units
    */
    public enum TMP_UNIT {
        case Celsius
        case Fahrenheit
        case Kelvin
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Defined by AppleSMC.kext. See SMCParamStruct.
    
    Function selectors. Used to tell the SMC which function inside it to call.
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
    }
    
    
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
    
    http://www.opensource.apple.com/source/PowerManagement/PowerManagement-211/
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
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
    Our connection to the SMC. Must init before passing it to IOServiceOpen()
    (hence zero value) and must close it when done.
    */
    private var conn : io_connect_t = 0
    
    
    /**
    Name of the SMC IOService as seen in the IORegistry. You can view it either
    via command line with ioreg or through the IORegistryExplorer app (found on
    Apple's developer site - Hardware IO Tools for Xcode)
    */
    private let IOSERVICE_SMC = "AppleSMC"
    
    
    /**
    IOService for get machine model name
    */
    private let IOSERVICE_MODEL = "IOPlatformExpertDevice"
    
    
    /**
    Number of characters in an SMC key
    */
    private let SMC_KEY_SIZE = 4
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    

    /**
    Open a connection to the SMC
    
    :returns: kIOReturnSuccess on successful connection to the SMC.
    */
    public func open() -> kern_return_t {
        var result  : kern_return_t
        var service : io_service_t
        
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                  IOServiceMatching(IOSERVICE_SMC).takeUnretainedValue())
        
        if (service == 0) {
            // NOTE: IOServiceMatching documents 0 on failure
            
            println("ERROR: \(IOSERVICE_SMC) NOT FOUND")
            return IOReturn.kIOReturnError.rawValue
        }
        
        result = IOServiceOpen(service, mach_task_self_, 0, &conn)
        IOObjectRelease(service)
        
        return result
    }
    
    
    /**
    Close connection to the SMC
    
    :returns: kIOReturnSuccess on successful close of connection to the SMC.
    */
    public func close() -> kern_return_t {
        return IOServiceClose(conn)
    }
    
    
    /**
    Get overall profile of the machine ("system information"), that is SMC
    related data and write to disk as JSON. Includes model number, valid
    temperature sensors (keys), and fan information.
    
    :returns: True if successful, false otherwise.
    */
    public func machineProfile(path : String) -> Bool {
        var result = false
        var err  : NSError?
        let data : [String : AnyObject] = ["Model"    : getMachineModel().model,
                                           "TMP Keys" : getAllValidTMPKeys(),
                                           "Fan Info" : getFanInfo()]
        
        let opts         = NSJSONWritingOptions.PrettyPrinted
        let outputStream = NSOutputStream(toFileAtPath: path, append: false)

        // Catch empty path string
        if (outputStream == nil) {
            return result
        }
        
        
        outputStream?.open()

        // Catch bad path - only once stream open
        if (outputStream?.streamStatus == NSStreamStatus.Error) {
            return result
        }
        
        // Check if write was successful
        // TODO: Log NSError on bad write
        if (NSJSONSerialization.writeJSONObject(data,
                                                toStream : outputStream!,
                                                options  : opts,
                                                error    : &err) != 0) {
            result = true
        }
        
        outputStream?.close()
        
        return result
    }
    
    
    /**
    Check if an SMC key is valid. Useful for determining if a certain machine
    has particular sensor or fan for example.
    
    NOTE: While a key may be valid, it can still report no data. This is a
          known issue with for example TMP.HEATSINK_0. Thus,
          getAllValidTMPKeys() discounts such sensors (even though isKeyValid()
          returns true).
    
    :param: key The SMC key to check. 4 byte multi-character constant. Must be
                4 characters in length.
    :returns: valid True if the key is found, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isKeyValid(key : String) -> (valid    : Bool,
                                             IOReturn : kern_return_t,
                                             kSMC     : UInt8) {
        var ans = false
                                                
        if (countElements(key) != SMC_KEY_SIZE) {
            println("ERROR: Invalid key size - must be 4 chars")
            return (ans, IOReturn.kIOReturnBadArgument.rawValue,
                         kSMC.kSMCError.rawValue)
        }

        // Try a read and see if it succeeds
        let result = readSMC(key)

        if (result.IOReturn == kIOReturnSuccess &&
            result.kSMC == kSMC.kSMCSuccess.rawValue) {
            ans = true
        }
                                                
        return (ans, result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get all valid SMC temperature keys (based on TMP enum, thus list may not
    be complete).
    
    NOTE: Any sensor that reports a temperature of 0 is discounted.
          TMP.HEATSINK_0 is known to do this.
    
    :returns: Dictionary of keys (name, TMP SMC key).
    */
    public func getAllValidTMPKeys() -> [String : String] {
        var keys = [String : String]()
        
        for (name, SMCKey) in TMP.allValues {
            if (isKeyValid(SMCKey.rawValue).valid &&
                readSMC(SMCKey.rawValue).data[0] != 0) {
                keys.updateValue(name, forKey: SMCKey.rawValue)
            }
        }
        
        return keys
    }
    
    
    /**
    Get the number of valid SMC keys for this machine.
    
    :returns: numKeys The number of SMC keys
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getNumSMCKeys() -> (numKeys  : UInt32,
                                    IOReturn : kern_return_t,
                                    kSMC     : UInt8) {
        let result = readSMC(SMC_KEY.NUM_KEYS.rawValue)
            
        // Type ui32 - size 4
        var numKeys = UInt32(result.data[0]) << 24
        numKeys += UInt32(result.data[1]) << 16
        numKeys += UInt32(result.data[2]) << 8
        numKeys += UInt32(result.data[3])
            
        return (numKeys, result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get the current temperature from a sensor
    
    :param: key The temperature sensor to read from
    :param: unit The unit for the temperature value (optional). Defaults to
                 Celsius.
    :returns: Temperature of sensor. If the sensor is not found, or an error
              occurs, return will be zero
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getTMP(key  : TMP,
                       unit : TMP_UNIT = TMP_UNIT.Celsius)
                                                   -> (tmp      : Double,
                                                       IOReturn : kern_return_t,
                                                       kSMC     : UInt8) {
       let result = readSMC(key.rawValue)
        
       // We drop the decimal value (data[1]) for now - thus maybe be off +/- 1
       // Data type is sp78 - signed floating point
       // http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
       var tmp = Double(result.data[0])
                                                        
       switch unit {
           case .Celsius:
               // Do nothing - in Celsius by default
               // Must have complete switch though with executed command
               tmp = tmp + 0
           case .Fahrenheit:
               tmp = SMC.toFahrenheit(tmp)
           case .Kelvin:
               tmp = SMC.toKelvin(tmp)
       }
    
       return (tmp, result.IOReturn, result.kSMC)
    }

    
    /**
    Is the machine being powered by the battery?
    
    :returns: flag True if it is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isBatteryPowered() -> (flag     : Bool,
                                       IOReturn : kern_return_t,
                                       kSMC     : UInt8) {
        let result = readSMC(SMC_KEY.BATT_PWR.rawValue)
        
        // Data type is flag - 1 bit. 1 if battery powered, 0 otherwise
        let ans = result.data[0] == 1 ? true : false
        
        return (ans, result.IOReturn, result.kSMC)
    }
    
    
    /**
    Is there a CD in the optical disk drive (ODD)?
    
    :returns: flag True if there is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isOpticalDiskDriveFull() -> (flag     : Bool,
                                             IOReturn : kern_return_t,
                                             kSMC     : UInt8) {
        let result = readSMC(SMC_KEY.ODD_FULL.rawValue)
        
        // Data type is flag - 1 bit. 1 if CD inserted, 0 otherwise
        let ans = result.data[0] == 1 ? true : false
            
        return (ans, result.IOReturn, result.kSMC)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - FANS
    //--------------------------------------------------------------------------
   
    
    /**
    Get the name of a fan.
    
    :param: fanNum The number of the fan to check
    :returns: name The name of the fan. Return will be empty on error.
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getFanName(fanNum : UInt) -> (name     : String,
                                              IOReturn : kern_return_t,
                                              kSMC     : UInt8) {
        var name = String()
        let result = readSMC("F" + String(fanNum) + "ID")
        
                                                
        /*
        We know the data size is 16 bytes and the type is "{fds", a custom
        struct defined by the AppleSMC.kext. See TMP enum sources for the
        struct.
        
        The last 12 bytes contain the name of the fan, an array of chars, hence
        the loop range.
        
        // TODO: Use dataSize value from readSMC()
        */
        for var i = 4; i < 16; ++i {
            // Check if at the end (name may not be full 12 bytes)
            if (result.data[i] <= 0) {
                break
            }
            name.append(UnicodeScalar(UInt32(result.data[i])))
        }


        // Strip whitespace (some names have it)
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        name = name.stringByTrimmingCharactersInSet(whitespace)

        return (name, result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get the current speed (RPM - revolutions per minute) of a fan.
    
    :param: fanNum The number of the fan to check
    :returns: rpm The fan RPM. If the fan is not found, or an error occurs,
                  return will be zero
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getFanRPM(fanNum : UInt) -> (rpm      : UInt,
                                             IOReturn : kern_return_t,
                                             kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNum) + "Ac")
        return (SMC.from_fpe2(result.data), result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get the minimum speed (RPM - revolutions per minute) of a fan.
    
    :param: fanNum The number of the fan to check
    :returns: rpm The minimum fan RPM. If the fan is not found, or an error
                  occurs, return will be zero
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getFanMinRPM(fanNum : UInt) -> (rpm      : UInt,
                                                IOReturn : kern_return_t,
                                                kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNum) + "Mn")
        return (SMC.from_fpe2(result.data), result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get the maximum speed (RPM - revolutions per minute) of a fan.
    
    :param: fanNum The number of the fan to check
    :returns: rpm The maximum fan RPM. If the fan is not found, or an error
                  occurs, return will be zero
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getFanMaxRPM(fanNum : UInt) -> (rpm      : UInt,
                                                IOReturn : kern_return_t,
                                                kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNum) + "Mx")
        return (SMC.from_fpe2(result.data), result.IOReturn, result.kSMC)
    }
    
    
    /**
    Get the number of fans on this machine.

    :returns: numFans The number of fans
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func getNumFans() -> (numFans  : UInt,
                                 IOReturn : kern_return_t,
                                 kSMC     : UInt8) {
        let result = readSMC(FAN.NUM_FANS.rawValue)
        return (UInt(result.data[0]), result.IOReturn, result.kSMC)
    }
    
    
    /**
    Set the minimum speed (RPM - revolutions per minute) of a fan. This method
    requires root privileges. By minimum we mean that OS X can interject and
    raise the fan speed if needed, however it will not go below this.

    WARNING: You are playing with hardware here, BE CAREFUL.
    
    :param: fanNum The number of the fan to set
    :param: rpm The speed you would like to set the fan to.
    :returns: result True if successful, false otherwise.
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func setFanMinRPM(fanNum : UInt, rpm : UInt) ->
                                                      (result   : Bool,
                                                       IOReturn : kern_return_t,
                                                       kSMC     : UInt8) {
        var ans = false
        
        // TODO: Cache value
        let maxRPM = getFanMaxRPM(fanNum)
                                                        
        // Safety check: rpm must be within safe range of fan speed
        // TODO: Add fan safe speed (F0Sf) to this check
        if (!(maxRPM.IOReturn == kIOReturnSuccess &&
              maxRPM.kSMC == kSMC.kSMCSuccess.rawValue &&
              rpm <= maxRPM.rpm)) {
                                                                
            println("WARNING: Unsafe fan RPM")
            return (ans, IOReturn.kIOReturnBadArgument.rawValue,
                         kSMC.kSMCError.rawValue)
        }
        
        // TODO: Don't use magic number for dataSize
        let result = writeSMC("F" + String(fanNum) + "Mn",
                              data     : SMC.to_fpe2(rpm),
                              dataType : DataType.FPE2,
                              dataSize : 2)
            
        if (result.IOReturn == kIOReturnSuccess &&
            result.kSMC == kSMC.kSMCSuccess.rawValue) {
            ans = true
        }
            
        return (ans, result.IOReturn, result.kSMC)
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------

    
    /**
    Read data from the SMC
    
    :param: key The SMC key
    :returns: Raw data return from the SMC
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    private func readSMC(key : String) -> (data     : [UInt8],
                                           dataType : UInt32,
                                           dataSize : IOByteCount,
                                           IOReturn : kern_return_t,
                                           kSMC     : UInt8) {
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        var data         = [UInt8](count: 32, repeatedValue: 0)
                                            
        
        // First call to AppleSMC - get key info
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.rawValue)
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        // Store for return - we only get this info on key info calls
        let dataType = outputStruct.keyInfo.dataType
        let dataSize = outputStruct.keyInfo.dataSize
        
        if (result != kIOReturnSuccess ||
            outputStruct.result != kSMC.kSMCSuccess.rawValue) {
            return (data, dataType, dataSize, result, outputStruct.result)
        }
        
        // Second call to AppleSMC - now we can get the data
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(Selector.kSMCReadKey.rawValue)

        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
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
        
        return (data, dataType, dataSize, result, outputStruct.result)
    }
    
    
    /**
    Write data to the SMC.
    
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    private func writeSMC(key      : String,
                          data     : [UInt8],
                          dataType : DataType,
                          dataSize : IOByteCount) -> (IOReturn : kern_return_t,
                                                      kSMC     : UInt8) {
                                                
        var result : kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        
        // First call to AppleSMC - get key info
        inputStruct.key = toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.rawValue)
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)
        
        if (result != kIOReturnSuccess ||
            outputStruct.result != kSMC.kSMCSuccess.rawValue) {
            return (result, outputStruct.result)
        }
        
        // Check if given data matches expected input
        if (dataSize != outputStruct.keyInfo.dataSize ||
            dataType.rawValue != toString(outputStruct.keyInfo.dataType)) {
            return (IOReturn.kIOReturnBadArgument.rawValue,
                    kSMC.kSMCError.rawValue)
        }
                                                        
        // Second call to AppleSMC - now we can write the data
        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = UInt8(Selector.kSMCWriteKey.rawValue)
        
        // Set data to write
        inputStruct.bytes_0  = data[0]
        inputStruct.bytes_1  = data[1]
        inputStruct.bytes_2  = data[2]
        inputStruct.bytes_3  = data[3]
        inputStruct.bytes_4  = data[4]
        inputStruct.bytes_5  = data[5]
        inputStruct.bytes_6  = data[6]
        inputStruct.bytes_7  = data[7]
        inputStruct.bytes_8  = data[8]
        inputStruct.bytes_9  = data[9]
        inputStruct.bytes_10 = data[10]
        inputStruct.bytes_11 = data[11]
        inputStruct.bytes_12 = data[12]
        inputStruct.bytes_13 = data[13]
        inputStruct.bytes_14 = data[14]
        inputStruct.bytes_15 = data[15]
        inputStruct.bytes_16 = data[16]
        inputStruct.bytes_17 = data[17]
        inputStruct.bytes_18 = data[18]
        inputStruct.bytes_19 = data[19]
        inputStruct.bytes_20 = data[20]
        inputStruct.bytes_21 = data[21]
        inputStruct.bytes_22 = data[22]
        inputStruct.bytes_23 = data[23]
        inputStruct.bytes_24 = data[24]
        inputStruct.bytes_25 = data[25]
        inputStruct.bytes_26 = data[26]
        inputStruct.bytes_27 = data[27]
        inputStruct.bytes_28 = data[28]
        inputStruct.bytes_29 = data[29]
        inputStruct.bytes_30 = data[30]
        inputStruct.bytes_31 = data[31]
        
        result = callSMC(&inputStruct, outputStruct : &outputStruct)

        return (result, outputStruct.result)
    }
    
    
    /**
    Make a call to the SMC
    
    :param: inputStruct Struct that holds data telling the SMC what you want
    :param: outputStruct Struct holding the SMC's response
    :returns: IOKit return code
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
            return IOReturn.kIOReturnBadArgument.rawValue
        }
        
        result = IOConnectCallStructMethod(conn,
                                           Selector.kSMCHandleYPCEvent.rawValue,
                                           &inputStruct,
                                           inputStructCnt,
                                           &outputStruct,
                                           &outputStructCnt)
        
        if (result != kIOReturnSuccess) {
            // Determine the exact error
            result = SMC.getErrorCode(result)
        }

        return result
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS
    //--------------------------------------------------------------------------


    /**
    Get overall information about the fans of the machine. For machineProfile().
    
    :returns: Dictionary of information.
    */
    private func getFanInfo() -> [String : AnyObject] {
        let numFans = getNumFans().numFans
        var profile : [String : AnyObject] = ["# of fans" : numFans]
        
        for var i : UInt = 0; i < numFans; ++i {
            // TODO: Add safe RPM
            let vals = ["Name"    : getFanName(i).name,
                        "Min RPM" : getFanMinRPM(i).rpm,
                        "Max RPM" : getFanMaxRPM(i).rpm]
            profile.updateValue(vals, forKey: "Fan \(i)")
        }
        
        return profile
    }
    

    /**
    Get the model name of the machine.
    
    :returns: The model name
    */
    private func getMachineModel() -> (model : String,
                                       IOReturn : kern_return_t) {
        var service : io_service_t
        var ptr     : UnsafeMutablePointer<Int8>
        
        var model          = String()
        var io_name_t_size = sizeof(io_name_t)
        
       
        // Find the service 
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                  IOServiceMatching(IOSERVICE_MODEL).takeUnretainedValue())
        
        if (service == 0) {
            return (model, IOReturn.kIOReturnError.rawValue)
        }
        
        
        ptr = UnsafeMutablePointer<Int8>.alloc(io_name_t_size)
        ptr.initialize(0)
        
        // Get the model name
        let result = IORegistryEntryGetName(service, ptr)
        IOObjectRelease(service)
        
        if (result == kIOReturnSuccess) {
            var next : Int8
            for var i = 0; i < io_name_t_size; ++i {
                next = ptr.advancedBy(i).memory
                
                // Check if at the end
                if (next <= 0) {
                    break
                }
                
                model.append(UnicodeScalar(UInt32(next)))
            }
        }
        
        
        // Clean up
        ptr.dealloc(io_name_t_size)
        
        return (model, result)
    }


    /**
    Convert SMC key to UInt32. This must be done to pass it to the SMC.
    
    :param: key The SMC key to convert
    :returns: UInt32 translation of it with little-endian representation.
              Returns zero if key is not 4 characters in length.
    */
    private func toUInt32(key : String) -> UInt32 {
        var ans   : Int32 = 0
        var shift : Int32 = 24

        // SMC key is expected to be 4 bytes - thus 4 chars
        if (countElements(key) != SMC_KEY_SIZE) {
            return 0
        }
        
        for char in key.utf8 {
            ans += (Int32(char) << shift)
            shift -= 8
        }
        
        return UInt32(ans).littleEndian
    }
    
    
    /**
    For converting the dataType return from the SMC to human readable
    4 byte multi-character constant.
    
    :param: dataType The data type as returned from a SMC read key info call
    :returns: 4-byte multi-character constant representation
    */
    private func toString(dataType : UInt32) -> String {
        var ans = String()
        var shift : Int32 = 24

        for var index = 0; index < SMC_KEY_SIZE; ++index {
            // To get each char, we shift it into the lower 8 bits, and then
            // & by 255 to insolate it
            var char = (Int32(dataType) >> shift) & 0xff
            
            ans.append(UnicodeScalar(UInt32(char)))
            shift -= 8
        }
        
        return ans
    }
    
    
    /**
    Convert data from SMC of fpe2 type to human readable
    
    :param: data Data from the SMC to be converted. Assumed data size of 2.
    :returns: Converted data
    */
    private class func from_fpe2(data : [UInt8]) -> UInt {
        var ans : UInt = 0
        
        // Data type for fan calls - fpe2
        // This is assumend to mean floating point, with 2 exponent bits
        // http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
        ans += UInt(data[0]) << 6
        ans += UInt(data[1]) >> 2
        
        return ans
    }
    
    
    /**
    Convert to fpe2 data type to be passed to SMC.
    
    :param: val Value to convert
    :return: Converted data in SMCParamStruct data format
    */
    private class func to_fpe2(val : UInt) -> [UInt8] {
        // TODO: check val size for overflow
        var data = [UInt8](count: 32, repeatedValue: 0)
        data[0] = UInt8(val >> 6)
        data[1] = UInt8((val << 2) ^ (UInt(data[0]) << 8))
        
        return data
    }
    
    
    /**
    IOReturn error code lookup
    
    See "Accessing Hardware From Applications -> Handling Errors" Apple doc for
    more information.
    
    :param: err The raw error code
    :returns: The IOReturn error code. If not found, returns the original error.
    */
    private class func getErrorCode(err : kern_return_t) -> kern_return_t {
        // kern_return_t is an Int32. The final 14 bits specify the error code
        // itself, hence the &
        let lookup : kern_return_t? = IOReturn(rawValue: err & 0x3fff)?.rawValue
        
        return (lookup ?? err)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS - TMP CONVERSION
    //--------------------------------------------------------------------------
    
    
    /**
    Celsius to Fahrenheit
    */
    private class func toFahrenheit(tmp : Double) -> Double {
        // http://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (tmp * 1.8) + 32
    }
    
    
    /**
    Celsius to Kelvin
    */
    private class func toKelvin(tmp : Double) -> Double {
        // http://en.wikipedia.org/wiki/Kelvin
        return tmp + 273.15
    }
}
