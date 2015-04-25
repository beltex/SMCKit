//
// SMC.swift
// SMCKit
//
// The MIT License
//
// Copyright (C) 2014, 2015  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import IOKit
import Foundation

//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC PROPERTIES
//------------------------------------------------------------------------------


/*
I/O Kit common error codes - as defined in <IOKit/IOReturn.h>

Swift can't import complex macros, thus we have to manually add them here.
Most of these are not relevant to us, but for the sake of completeness. See
"Accessing Hardware From Applications -> Handling Errors" Apple document for
more information.

NOTE: kIOReturnSuccess is the only return code already defined in IOKit module
      for us.

https://developer.apple.com/library/mac/qa/qa1075/_index.html
*/


/// General error
public let kIOReturnError            = iokit_common_err(0x2bc)
/// Can't allocate memory
public let kIOReturnNoMemory         = iokit_common_err(0x2bd)
/// Resource shortage
public let kIOReturnNoResources      = iokit_common_err(0x2be)
/// Error during IPC
public let kIOReturnIPCError         = iokit_common_err(0x2bf)
/// No such device
public let kIOReturnNoDevice         = iokit_common_err(0x2c0)
/// Privilege violation
public let kIOReturnNotPrivileged    = iokit_common_err(0x2c1)
/// Invalid argument
public let kIOReturnBadArgument      = iokit_common_err(0x2c2)
/// Device read locked
public let kIOReturnLockedRead       = iokit_common_err(0x2c3)
/// Exclusive access and device already open
public let kIOReturnExclusiveAccess  = iokit_common_err(0x2c5)
/// Sent/received messages had different msg_id
public let kIOReturnBadMessageID     = iokit_common_err(0x2c6)
/// Unsupported function
public let kIOReturnUnsupported      = iokit_common_err(0x2c7)
/// Misc. VM failure
public let kIOReturnVMError          = iokit_common_err(0x2c8)
/// Internal error
public let kIOReturnInternalError    = iokit_common_err(0x2c9)
/// General I/O error
public let kIOReturnIOError          = iokit_common_err(0x2ca)
/// Can't acquire lock
public let kIOReturnCannotLock       = iokit_common_err(0x2cc)
/// Device not open
public let kIOReturnNotOpen          = iokit_common_err(0x2cd)
/// Read not supported
public let kIOReturnNotReadable      = iokit_common_err(0x2ce)
/// Write not supported
public let kIOReturnNotWritable      = iokit_common_err(0x2cf)
/// Alignment error
public let kIOReturnNotAligned       = iokit_common_err(0x2d0)
/// Media Error
public let kIOReturnBadMedia         = iokit_common_err(0x2d1)
/// Device(s) still open
public let kIOReturnStillOpen        = iokit_common_err(0x2d2)
/// RLD failure
public let kIOReturnRLDError         = iokit_common_err(0x2d3)
/// DMA failure
public let kIOReturnDMAError         = iokit_common_err(0x2d4)
/// Device Busy
public let kIOReturnBusy             = iokit_common_err(0x2d5)
/// I/O Timeout
public let kIOReturnTimeout          = iokit_common_err(0x2d6)
/// Device offline
public let kIOReturnOffline          = iokit_common_err(0x2d7)
/// Not ready
public let kIOReturnNotReady         = iokit_common_err(0x2d8)
/// Device not attached
public let kIOReturnNotAttached      = iokit_common_err(0x2d9)
/// No DMA channels left
public let kIOReturnNoChannels       = iokit_common_err(0x2da)
/// No space for data
public let kIOReturnNoSpace          = iokit_common_err(0x2db)
/// Port already exists
public let kIOReturnPortExists       = iokit_common_err(0x2dd)
/// Can't wire down physical memory
public let kIOReturnCannotWire       = iokit_common_err(0x2de)
/// No interrupt attached
public let kIOReturnNoInterrupt      = iokit_common_err(0x2df)
/// No DMA frames enqueued
public let kIOReturnNoFrames         = iokit_common_err(0x2e0)
/// Oversized msg received on interrupt port
public let kIOReturnMessageTooLarge  = iokit_common_err(0x2e1)
/// Not permitted
public let kIOReturnNotPermitted     = iokit_common_err(0x2e2)
/// No power to device
public let kIOReturnNoPower          = iokit_common_err(0x2e3)
/// Media not present
public let kIOReturnNoMedia          = iokit_common_err(0x2e4)
/// Media not formatted
public let kIOReturnUnformattedMedia = iokit_common_err(0x2e5)
/// No such mode
public let kIOReturnUnsupportedMode  = iokit_common_err(0x2e6)
/// Data underrun
public let kIOReturnUnderrun         = iokit_common_err(0x2e7)
/// Data overrun
public let kIOReturnOverrun          = iokit_common_err(0x2e8)
/// The device is not working properly!
public let kIOReturnDeviceError      = iokit_common_err(0x2e9)
/// A completion routine is required
public let kIOReturnNoCompletion     = iokit_common_err(0x2ea)
/// Operation aborted
public let kIOReturnAborted          = iokit_common_err(0x2eb)
/// Bus bandwidth would be exceeded
public let kIOReturnNoBandwidth      = iokit_common_err(0x2ec)
/// Device not responding
public let kIOReturnNotResponding    = iokit_common_err(0x2ed)
/// Isochronous I/O request for distant past!
public let kIOReturnIsoTooOld        = iokit_common_err(0x2ee)
/// Isochronous I/O request for distant future
public let kIOReturnIsoTooNew        = iokit_common_err(0x2ef)
/// Data was not found
public let kIOReturnNotFound         = iokit_common_err(0x2f0)
/// Should never be seen
public let kIOReturnInvalid          = iokit_common_err(0x1)


//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE PROPERTIES
//------------------------------------------------------------------------------


/**
I/O Kit system code is 0x38. First 6 bits of error code. Passed to err_system()
macro as defined in <mach/error.h>.
*/
private let SYS_IOKIT: UInt32 = (0x38 & 0x3f) << 26


/**
I/O Kit subsystem code is 0. Middle 12 bits of error code. Passed to err_sub()
macro as defined in <mach/error.h>.
*/
private let SUB_IOKIT_COMMON: UInt32 = (0 & 0xfff) << 14


//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE FUNCTIONS
//------------------------------------------------------------------------------


/**
Based on macro of the same name in <IOKit/IOReturn.h>. Generates the error code.

:param: code The specific I/O Kit error code. Last 14 bits.
:returns: Full 32 bit error code.
*/
private func iokit_common_err(code: UInt32) -> kern_return_t {
    // Overflow otherwise
    return Int32(bitPattern: SYS_IOKIT | SUB_IOKIT_COMMON | code)
}


/**
System Management Controller (SMC) API from user space for Intel based Macs.
Works by talking to the AppleSMC.kext (kernel extension), the closed source
driver for the SMC.
*/
public struct SMC {


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
    public enum Temperature: String {
        // TODO: Add more CPU and GPU keys. GPU is usually maxed at 2, see Mac
        //       Pro & 15' Macbook Pro. Not sure what max CPU's is though. We
        //       can get the value via Mach API at runtime but that won't help.

        case AMBIENT_AIR_0          = "TA0P"
        case AMBIENT_AIR_1          = "TA1P"
        /// This key was found via Apple's own powermetrics tool
        case CPU_0_DIE              = "TC0F"
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
        case PALM_REST              = "Ts0P"
        case PWR_SUPPLY_PROXIMITY   = "Tp0P"
        case THUNDERBOLT_0          = "TI0P"
        case THUNDERBOLT_1          = "TI1P"
        // See https://github.com/beltex/SMCKit/issues/15
        //case WIRELESS_MODULE        = "TW0P"


        /**
        For enumerating all values of the enum. Not ideal. Seems to be the
        cleanest current solution. See: http://stackoverflow.com/a/24137319

        Also, for getting the name of the enum, again, currently no way to do
        this in Swift.
        */
        public static let allValues =
                               [AMBIENT_AIR_0         : "AMBIENT_AIR_0",
                                AMBIENT_AIR_1         : "AMBIENT_AIR_1",
                                CPU_0_DIE             : "CPU_0_DIE",
                                CPU_0_DIODE           : "CPU_0_DIODE",
                                CPU_0_HEATSINK        : "CPU_0_HEATSINK",
                                CPU_0_PROXIMITY       : "CPU_0_PROXIMITY",
                                ENCLOSURE_BASE_0      : "ENCLOSURE_BASE_0",
                                ENCLOSURE_BASE_1      : "ENCLOSURE_BASE_1",
                                ENCLOSURE_BASE_2      : "ENCLOSURE_BASE_2",
                                ENCLOSURE_BASE_3      : "ENCLOSURE_BASE_3",
                                GPU_0_DIODE           : "GPU_0_DIODE",
                                GPU_0_HEATSINK        : "GPU_0_HEATSINK",
                                GPU_0_PROXIMITY       : "GPU_0_PROXIMITY",
                                HDD_PROXIMITY         : "HDD_PROXIMITY",
                                HEATSINK_0            : "HEATSINK_0",
                                HEATSINK_1            : "HEATSINK_1",
                                HEATSINK_2            : "HEATSINK_2",
                                LCD_PROXIMITY         : "LCD_PROXIMITY",
                                MEM_SLOT_0            : "MEM_SLOT_0",
                                MEM_SLOTS_PROXIMITY   : "MEM_SLOTS_PROXIMITY",
                                MISC_PROXIMITY        : "MISC_PROXIMITY",
                                NORTHBRIDGE           : "NORTHBRIDGE",
                                NORTHBRIDGE_DIODE     : "NORTHBRIDGE_DIODE",
                                NORTHBRIDGE_PROXIMITY : "NORTHBRIDGE_PROXIMITY",
                                ODD_PROXIMITY         : "ODD_PROXIMITY",
                                PALM_REST             : "PALM_REST",
                                PWR_SUPPLY_PROXIMITY  : "PWR_SUPPLY_PROXIMITY",
                                THUNDERBOLT_0         : "THUNDERBOLT_0",
                                THUNDERBOLT_1         : "THUNDERBOLT_1"]
                                //WIRELESS_MODULE       : "WIRELESS_MODULE"]
    }


    /// Temperature units
    public enum TemperatureUnit {
        case Celsius
        case Fahrenheit
        case Kelvin
    }


    /**
    Defined by AppleSMC.kext. See SMCParamStruct.

    These are SMC specific return codes
    */
    public enum kSMC: UInt8 {
        case kSMCSuccess     = 0
        case kSMCError       = 1
        case kSMCKeyNotFound = 0x84
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------


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

    Sources: See Temperature enum
    */
    private enum Fan: String {
        case COUNT            = "FNum"
        case FAN_0            = "F0Ac"
        case FAN_0_DESC       = "F0ID"
        case FAN_0_MIN_RPM    = "F0Mn"
        case FAN_0_MAX_RPM    = "F0Mx"
        case FAN_0_SAFE_RPM   = "F0Sf"
        case FAN_0_TARGET_RPM = "F0Tg"
    }


    /**
    Misc SMC keys - 4 byte multi-character constants

    Sources: See Temperature enum
    */
    private enum SMCKeyMisc: String {
        /// Battery information
        case BATT_INFO = "BSIn"

        /// Max number of batteries
        case BATT_MAX_NUM = "BNum"

        /// Is the machine being powered by the battery?
        case BATT_PWR  = "BATP"

        /// How many SMC keys does this machine have?
        case NUM_KEYS  = "#KEY"

        /// Is there a CD in the optical disk drive (ODD)?
        case ODD_FULL  = "MSDI"
    }


    /**
    SMC data types - 4 byte multi-character constants

    Sources: See Temperature enum

    http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
    */
    private enum DataType: String {
        case FLAG = "flag"
        case FPE2 = "fpe2"
        case SFDS = "{fds"
        case SP78 = "sp78"
    }


    /**
    Defined by AppleSMC.kext. See SMCParamStruct.

    Function selectors. Used to tell the SMC which function inside it to call.
    */
    private enum Selector: UInt32 {
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


    /// Defined by AppleSMC.kext. See SMCParamStruct.
    private struct SMCVersion {
        var major    : CUnsignedChar  = 0
        var minor    : CUnsignedChar  = 0
        var build    : CUnsignedChar  = 0
        var reserved : CUnsignedChar  = 0
        var release  : CUnsignedShort = 0
    }


    /// Defined by AppleSMC.kext. See SMCParamStruct.
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
      instead. See issue #11.
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


    /// Our connection to the SMC
    private var conn: io_connect_t = 0


    /**
    Name of the SMC IOService as seen in the IORegistry. You can view it either
    via command line with ioreg or through the IORegistryExplorer app (found on
    Apple's developer site - Hardware IO Tools for Xcode)
    */
    private static let IOSERVICE_SMC = "AppleSMC"


    /// Number of characters in an SMC key
    private static let SMC_KEY_SIZE = 4


    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------


    // http://stackoverflow.com/a/25598333
    public init() { }


    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------


    /**
    Open a connection to the SMC

    :returns: kIOReturnSuccess on successful connection to the SMC.
    */
    public mutating func open() -> kern_return_t {
        // TODO: Why does calling open() twice (without below) return success?
        if (conn != 0) {
            #if DEBUG
                println("WARNING - \(__FILE__):\(__FUNCTION__) - " +
                        "\(SMC.IOSERVICE_SMC) connection already open")
            #endif
            return kIOReturnStillOpen
        }


        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                     IOServiceMatching(SMC.IOSERVICE_SMC).takeUnretainedValue())

        if (service == 0) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - " +
                        "\(SMC.IOSERVICE_SMC) service not found")
            #endif

            return kIOReturnError
        }

        let result = IOServiceOpen(service, mach_task_self_, 0, &conn)
        IOObjectRelease(service)

        return result
    }


    /**
    Close connection to the SMC

    :returns: kIOReturnSuccess on successful close of connection to the SMC.
    */
    public mutating func close() -> kern_return_t {
        // Calling close twice or if connection not open returns the Mach IPC
        // error - MACH_SEND_INVALID_DEST
        let result = IOServiceClose(conn)
        conn = 0    // Reset this incase open() is called again

        #if DEBUG
            if (result != kIOReturnSuccess) {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - Failed to close")
            }
        #endif

        return result
    }


    /**
    Check if an SMC key is valid. Useful for determining if a certain machine
    has particular sensor or fan for example.

    NOTE: While a key may be valid, it can still report no data. This is a
          known issue with for example Temperature.HEATSINK_0. Thus,
          getAllValidTemperatureKeys() discounts such sensors (even though
          isKeyValid() returns true).

    :param: key The SMC key to check. 4 byte multi-character constant. Must be
                4 characters in length.
    :returns: valid True if the key is found, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isKeyValid(key: String) -> (valid    : Bool,
                                            IOReturn : kern_return_t,
                                            kSMC     : UInt8) {
        var ans = false

        if (count(key) != SMC.SMC_KEY_SIZE) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - INVALID KEY" +
                        "SIZE")
            #endif
            return (ans, kIOReturnBadArgument, kSMC.kSMCError.rawValue)
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
    Get all valid SMC temperature keys (based on Temperature enum, thus list
    may not be complete).

    NOTE: Any sensor that reports a temperature of 0 is discounted.
          Temperature.HEATSINK_0 is known to do this.

    :returns: Array of keys. For convenience, the array is sorted based on
              sensor names.
    */
    public func getAllValidTemperatureKeys() -> [Temperature] {
        var SMCKeys = [Temperature]()

        for SMCKey in Temperature.allValues.keys.array {
            if (isKeyValid(SMCKey.rawValue).valid &&
                readSMC(SMCKey.rawValue).data[0] != 0) {
                SMCKeys.append(SMCKey)
            }
        }

        return sorted(SMCKeys, { Temperature.allValues[$0]! <
                                 Temperature.allValues[$1]! })
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
        let result = readSMC(SMCKeyMisc.NUM_KEYS.rawValue)

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
    public func getTemperature(key  : Temperature,
                               unit : TemperatureUnit = .Celsius) ->
                                                      (tmp      : Double,
                                                       IOReturn : kern_return_t,
                                                       kSMC     : UInt8) {
       let result = readSMC(key.rawValue)

       // We drop the decimal value (data[1]) for now - thus maybe be off +/- 1
       // Data type is sp78 - signed floating point
       // http://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types
       var tmp = Double(result.data[0])

       switch unit {
           case .Celsius:
               // Do nothing, in Celsius by default
               break
           case .Fahrenheit:
               tmp = SMC.toFahrenheit(tmp)
           case .Kelvin:
               tmp = SMC.toKelvin(tmp)
       }

       return (tmp, result.IOReturn, result.kSMC)
    }


    /**
    Is there a CD in the optical disk drive (ODD)?

    NOTE: This almost certainly does not apply to an external ODD, like an Apple
          USB SuperDrive. This is yet to be tested.
    TODO: What if its a 3rd party ODD that was swapped internally?
    TODO: What about the old Mac Pro that can have 2 ODD?

    :returns: flag True if there is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isOpticalDiskDriveFull() -> (flag     : Bool,
                                             IOReturn : kern_return_t,
                                             kSMC     : UInt8) {
        let result = readSMC(SMCKeyMisc.ODD_FULL.rawValue)

        // Data type is flag - 1 bit. 1 if CD inserted, 0 otherwise
        let flag = result.data[0] == 1 ? true : false

        return (flag, result.IOReturn, result.kSMC)
    }


    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - BATTERY/POWER
    //--------------------------------------------------------------------------


    /**
    Max number of batteries supported by the machine. For desktops, this should
    be 0, and 1 for laptops.

    :returns: count Max number of batteries supported by the machine
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func maxNumberBatteries() -> (count    : UInt,
                                         IOReturn : kern_return_t,
                                         kSMC     : UInt8) {
        let result = readSMC(SMCKeyMisc.BATT_MAX_NUM.rawValue)

        // TODO: return -1 on error and get rid of return codes. See issue #8.
        return (UInt(result.data[0]), result.IOReturn, result.kSMC)
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
        let result = readSMC(SMCKeyMisc.BATT_PWR.rawValue)

        // Data type is flag - 1 bit. 1 if battery powered, 0 otherwise
        let flag = result.data[0] == 1 ? true : false

        return (flag, result.IOReturn, result.kSMC)
    }


    /**
    Is the machine charing?

    :returns: flag True if it is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isCharging() -> (flag     : Bool,
                                 IOReturn : kern_return_t,
                                 kSMC     : UInt8) {
        let result = readSMC(SMCKeyMisc.BATT_INFO.rawValue)

        // First bit contains the charging flag
        let flag = (result.data[0] & 1) == 1 ? true : false

        return (flag, result.IOReturn, result.kSMC)
    }


    /**
    Is AC power present?

    :returns: flag True if it is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isACPresent() -> (flag     : Bool,
                                  IOReturn : kern_return_t,
                                  kSMC     : UInt8) {
        let result = readSMC(SMCKeyMisc.BATT_INFO.rawValue)

        // Second bit contains the AC present flag
        let flag = ((result.data[0] >> 1) & 1) == 1 ? true : false

        return (flag, result.IOReturn, result.kSMC)
    }


    /**
    Is the battery ok? Currently no details on exactly what this entails. Even
    if service battery warning is given by OS X, this still seems to return OK.

    :returns: flag True if it is, false otherwise
    :returns: IOReturn IOKit return code
    :returns: kSMC SMC return code
    */
    public func isBatteryOk() -> (flag     : Bool,
                                  IOReturn : kern_return_t,
                                  kSMC     : UInt8) {
        let result = readSMC(SMCKeyMisc.BATT_INFO.rawValue)

        // Sixth bit contains the battery ok flag
        let flag = ((result.data[0] >> 6) & 1) == 1 ? true : false

        return (flag, result.IOReturn, result.kSMC)
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
    public func getFanName(fanNumber: UInt) -> (name     : String,
                                                IOReturn : kern_return_t,
                                                kSMC     : UInt8) {
        var name = String()
        let result = readSMC("F" + String(fanNumber) + "ID")


        /*
        We know the data size is 16 bytes and the type is "{fds", a custom
        struct defined by the AppleSMC.kext. See Temperature enum sources for
        the struct.

        The last 12 bytes contain the name of the fan, an array of chars, hence
        the loop range.

        TODO: Use dataSize value from readSMC()
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
    public func getFanRPM(fanNumber: UInt) -> (rpm      : UInt,
                                               IOReturn : kern_return_t,
                                               kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNumber) + "Ac")
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
    public func getFanMinRPM(fanNumber: UInt) -> (rpm      : UInt,
                                                  IOReturn : kern_return_t,
                                                  kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNumber) + "Mn")
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
    public func getFanMaxRPM(fanNumber: UInt) -> (rpm      : UInt,
                                                  IOReturn : kern_return_t,
                                                  kSMC     : UInt8) {
        let result = readSMC("F" + String(fanNumber) + "Mx")
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
        let result = readSMC(Fan.COUNT.rawValue)
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
    */
    public func setFanMinRPM(fanNumber: UInt, RPM: UInt) ->
                                                      (result  : Bool,
                                                       IOReturn: kern_return_t,
                                                       kSMC    : UInt8) {
        // TODO: Cache value
        let maxRPM = getFanMaxRPM(fanNumber)

        // Safety check. RPM must be within safe range of fan speed
        if !(maxRPM.IOReturn == kIOReturnSuccess &&
             maxRPM.kSMC == kSMC.kSMCSuccess.rawValue &&
             RPM <= maxRPM.rpm) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - UNSAFE RPM - " +
                        "Max \(maxRPM.rpm) RPM")
            #endif

            return (false, kIOReturnBadArgument, kSMC.kSMCError.rawValue)
        }

        // Prep data
        let encodedRPM = SMC.encodeFPE2(UInt16(RPM))
        var data = [UInt8](count: 32, repeatedValue: 0)
        data[0] = encodedRPM.0
        data[1] = encodedRPM.1

        // TODO: Don't use magic number for dataSize
        let result = writeSMC("F" + String(fanNumber) + "Mn", data: data,
                              dataType: DataType.FPE2,
                              dataSize: 2)

        var answer = false
        if result.IOReturn == kIOReturnSuccess &&
           result.kSMC     == kSMC.kSMCSuccess.rawValue {
            answer = true
        }

        return (answer, result.IOReturn, result.kSMC)
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
    private func readSMC(key: String) -> (data     : [UInt8],
                                          dataType : UInt32,
                                          dataSize : IOByteCount,
                                          IOReturn : kern_return_t,
                                          kSMC     : UInt8) {
        var result: kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()
        var data         = [UInt8](count: 32, repeatedValue: 0)


        // First call to AppleSMC - get key info
        inputStruct.key = SMC.toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.rawValue)

        result = callSMC(&inputStruct, outputStruct: &outputStruct)

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

        result = callSMC(&inputStruct, outputStruct: &outputStruct)

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
        var result: kern_return_t
        var inputStruct  = SMCParamStruct()
        var outputStruct = SMCParamStruct()

        // First call to AppleSMC - get key info
        inputStruct.key = SMC.toUInt32(key)
        inputStruct.data8 = UInt8(Selector.kSMCGetKeyInfo.rawValue)

        result = callSMC(&inputStruct, outputStruct: &outputStruct)

        if (result != kIOReturnSuccess ||
            outputStruct.result != kSMC.kSMCSuccess.rawValue) {
            return (result, outputStruct.result)
        }

        // Check if given data matches expected input
        if (dataSize != outputStruct.keyInfo.dataSize ||
            dataType.rawValue != SMC.UInt32toString(outputStruct.keyInfo.dataType)) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - INVALID DATA - "
                        + "Expected input = \(outputStruct.keyInfo)")
            #endif
            return (kIOReturnBadArgument, kSMC.kSMCError.rawValue)
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

        result = callSMC(&inputStruct, outputStruct: &outputStruct)

        return (result, outputStruct.result)
    }


    /**
    Make a call to the SMC

    :param: inputStruct Struct that holds data telling the SMC what you want
    :param: outputStruct Struct holding the SMC's response
    :returns: IOKit return code
    */
    private func callSMC(inout inputStruct : SMCParamStruct,
                         inout outputStruct: SMCParamStruct) -> kern_return_t {
        let inputStructSize  = strideof(SMCParamStruct)
        var outputStructSize = strideof(SMCParamStruct)


        #if DEBUG
            // Depending how far off this is from 80, call may or may not
            // work
            if inputStructSize != 80 {
                println("WARNING - \(__FILE__):\(__FUNCTION__) - SMCParamStruct"
                        + " size is \(inputStructSize) bytes. Expected 80")

                return kIOReturnBadArgument
            }
        #endif


        let result = IOConnectCallStructMethod(conn,
                                           Selector.kSMCHandleYPCEvent.rawValue,
                                           &inputStruct,
                                           inputStructSize,
                                           &outputStruct,
                                           &outputStructSize)


        #if DEBUG
            if result != kIOReturnSuccess {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - IOReturn = " +
                        "\(result) - kSMC = \(outputStruct.result)")
            }
        #endif

        return result
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS
    //--------------------------------------------------------------------------


    /**
    Convert SMC key to UInt32. This must be done to pass it to the SMC.

    :param: key The SMC key to convert
    :returns: UInt32 translation of it with little-endian representation.
              Returns zero if key is not 4 characters in length.
    */
    private static func toUInt32(key: String) -> UInt32 {
        var ans   : Int32 = 0
        var shift : Int32 = 24

        // SMC key is expected to be 4 bytes - thus 4 chars
        if (count(key) != SMC_KEY_SIZE) {
            return 0
        }

        // TODO: Loop unrolling?
        for char in key.utf8 {
            ans += (Int32(char) << shift)
            shift -= 8
        }

        return UInt32(ans).littleEndian
    }


    /**
    Convert UInt32 value to 4 character String. For decoding SMCParamStruct.key,
    SMCKeyInfoData.dataType, etc.
    */
    private static func UInt32toString(value: UInt32) -> String {
        // To get each char, we shift it into the lower 8 bits, and then
        // & by 255 to insolate it
        return String(UnicodeScalar(value >> 24 & 0xff)) +
               String(UnicodeScalar(value >> 16 & 0xff)) +
               String(UnicodeScalar(value >> 8  & 0xff)) +
               String(UnicodeScalar(value       & 0xff))
    }


    /**
    Convert data from SMC of fpe2 type to human readable. For example, fan RPM
    is of this data type. This is assumend to mean floating point, with 2
    exponent bits.

    https://stackoverflow.com/questions/22160746/fpe2-and-sp78-data-types

    :param: data Data from the SMC to be converted. Assumed data size of 2.
    :returns: Converted data
    */
    private static func from_fpe2(data: [UInt8]) -> UInt {
        return (UInt(data[0]) << 6) + (UInt(data[1]) >> 2)
    }


    /**
    Convert value to fpe2 data type. For passing to SMC, used for fan RPM for
    example.
    */
    public static func encodeFPE2(value: UInt16) -> (UInt8, UInt8) {
        return (UInt8(value >> 6),
                UInt8((value << 2) ^ ((value >> 6) << 8)))
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS - TEMPERATURE CONVERSION
    //--------------------------------------------------------------------------


    /**
    Celsius to Fahrenheit

    :param: temperature Temperature in Celsius
    :returns: Temperature in Fahrenheit
    */
    private static func toFahrenheit(temperature: Double) -> Double {
        // https://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (temperature * 1.8) + 32
    }


    /**
    Celsius to Kelvin

    :param: temperature Temperature in Celsius
    :returns: Temperature in Kelvin
    */
    private static func toKelvin(temperature: Double) -> Double {
        // https://en.wikipedia.org/wiki/Kelvin
        return temperature + 273.15
    }
}
