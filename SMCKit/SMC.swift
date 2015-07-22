//
// SMC.swift
// SMCKit
//
// The MIT License
//
// Copyright (C) 2015  beltex <https://github.com/beltex>
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
// MARK: Type Aliases
//------------------------------------------------------------------------------

// http://stackoverflow.com/a/22383661

/// Floating point, unsigned, 14 bits exponent, 2 bits fraction
public typealias FPE2 = (UInt8, UInt8)

/// Floating point, signed, 7 bits exponent, 8 bits fraction
public typealias SP78 = (UInt8, UInt8)

public typealias SMCBytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                             UInt8, UInt8, UInt8, UInt8)

//------------------------------------------------------------------------------
// MARK: Standard Library Extensions
//------------------------------------------------------------------------------

extension UInt32 {

    init(fromBytes bytes: (UInt8, UInt8, UInt8, UInt8)) {
        self = UInt32(bytes.0) << 24 |
               UInt32(bytes.1) << 16 |
               UInt32(bytes.2) << 8  |
               UInt32(bytes.3)
    }
}

extension Bool {

    init(fromByte byte: UInt8) {
        self = byte == 1 ? true : false
    }
}

extension Int {

    init(fromFPE2 bytes: FPE2) {
        self = (Int(bytes.0) << 6) + (Int(bytes.1) >> 2)
    }

    func toFPE2() -> FPE2 {
        return (UInt8(self >> 6), UInt8((self << 2) ^ ((self >> 6) << 8)))
    }
}

extension Double {

    init(fromSP78 bytes: SP78) {
        // FIXME: Handle second byte
        self = Double(bytes.0)
    }
}

// http://airspeedvelocity.net/2015/05/22/my-talk-at-swift-summit/
extension FourCharCode {

    init(fromString str: String) {
        precondition(str.characters.count == 4)

        self = str.utf8.reduce(0) { sum, character in
            return sum << 8 | UInt32(character)
        }
    }

    init(fromStaticString str: StaticString) {
        precondition(str.byteSize == 4)

        self = str.withUTF8Buffer { (buffer) -> UInt32 in
            // FIXME: Compiler hang, need to break up expression
            let temp = UInt32(buffer[0]) << 24
            return temp                    |
                   UInt32(buffer[1]) << 16 |
                   UInt32(buffer[2]) << 8  |
                   UInt32(buffer[3])
        }
    }

    func toString() -> String {
        return String(UnicodeScalar(self >> 24 & 0xff)) +
               String(UnicodeScalar(self >> 16 & 0xff)) +
               String(UnicodeScalar(self >> 8  & 0xff)) +
               String(UnicodeScalar(self       & 0xff))
    }
}

//------------------------------------------------------------------------------
// MARK: Defined by AppleSMC.kext
//------------------------------------------------------------------------------

/// Defined by AppleSMC.kext
/// TODO: Note IOKit param stuff
///
/// This is the predefined struct that must be passed to communicate with the
/// AppleSMC driver. While the driver is closed source, the definition of this
/// struct happened to appear in the Apple PowerManagement project at around
/// version 211, and soon after disappeared. It can be seen in the PrivateLib.c
/// file under pmconfigd. Given that it is C code, this is the closest
/// translation to Swift from a type perspective.
///
/// ### Issues
///
/// * Padding for struct alignment when passed over to C side
/// * Size of struct must be 80 bytes
/// * C array's are bridged as tuples
///
/// http://www.opensource.apple.com/source/PowerManagement/PowerManagement-211/
public struct SMCParamStruct {

    /// I/O Kit function selector
    public enum Selector: UInt8 {
        case kSMCHandleYPCEvent  = 2
        case kSMCReadKey         = 5
        case kSMCWriteKey        = 6
        case kSMCGetKeyFromIndex = 8
        case kSMCGetKeyInfo      = 9
    }

    /// Return codes for SMCParamStruct.result property
    public enum Result: UInt8 {
        case kSMCSuccess     = 0
        case kSMCError       = 1
        case kSMCKeyNotFound = 132
    }

    public struct SMCVersion {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }

    public struct SMCPLimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    public struct SMCKeyInfoData {
        /// How many bytes written to SMCParamStruct.bytes
        var dataSize: IOByteCount = 0

        /// Type of data written to SMCParamStruct.bytes. This lets us know how
        /// to interpret it (translate it to human readable)
        var dataType: UInt32 = 0

        var dataAttributes: UInt8 = 0
    }

    /// FourCharCode telling the SMC what we want
    var key: UInt32 = 0

    var vers = SMCVersion()

    var pLimitData = SMCPLimitData()

    var keyInfo = SMCKeyInfoData()

    /// Padding for struct alignment when passed over to C side
    var padding: UInt16 = 0

    /// Result of an operation
    var result: UInt8 = 0

    var status: UInt8 = 0

    /// Method selector
    var data8: UInt8 = 0

    var data32: UInt32 = 0

    /// Data returned from the SMC
    var bytes = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                 UInt8(0), UInt8(0))
}

//------------------------------------------------------------------------------
// MARK: SMC Client
//------------------------------------------------------------------------------

/// I/O Kit common error codes - as defined in <IOKit/IOReturn.h>
///
/// Swift currently can't import complex macros, thus we have to manually add
/// them here.

/// Privilege violation
private let kIOReturnNotPrivileged = iokit_common_err(0x2c1)

/// Based on macro of the same name in <IOKit/IOReturn.h>. Generates the full
/// 32-bit error code.
///
/// - parameter code: The specific I/O Kit error code. Last 14 bits
private func iokit_common_err(code: Int32) -> kern_return_t {
    // I/O Kit system code is 0x38. First 6 bits of error code. Passed to
    // err_system() macro as defined in <mach/error.h>
    let SYS_IOKIT: Int32 = (0x38 & 0x3f) << 26

    // I/O Kit subsystem code is 0. Middle 12 bits of error code. Passed to
    // err_sub() macro as defined in <mach/error.h>
    let SUB_IOKIT_COMMON: Int32 = (0 & 0xfff) << 14

    return SYS_IOKIT | SUB_IOKIT_COMMON | code
}


/// FIXME: Comments
let dataTypeFDS  = DataType(type: FourCharCode(fromStaticString: "{fds"),
                                                                       size: 16)
let dataTypeFLAG = DataType(type: FourCharCode(fromStaticString: "flag"),
                                                                        size: 1)
let dataTypeFPE2 = DataType(type: FourCharCode(fromStaticString: "fpe2"),
                                                                        size: 2)
let dataTypeSP78 = DataType(type: FourCharCode(fromStaticString: "sp78"),
                                                                        size: 2)
let dataTypeUI8  = DataType(type: FourCharCode(fromStaticString: "ui8 "),
                                                                        size: 1)
let dataTypeUI32 = DataType(type: FourCharCode(fromStaticString: "ui32"),
                                                                        size: 4)

public struct SMCKey {
    let code: FourCharCode
    let info: DataType
}

public struct DataType: Equatable {
    let type: FourCharCode
    let size: UInt32
}

public func ==(lhs: DataType, rhs: DataType) -> Bool {
    return lhs.type == rhs.type && lhs.size == rhs.size
}

/// Apple System Management Controller (SMC) user-space client for Intel-based
/// Macs. Works by talking to the AppleSMC.kext (kernel extension), the closed
/// source driver for the SMC.
public struct SMCKit {

    public enum Error: ErrorType {
        /// AppleSMC driver not found
        case DriverNotFound

        /// Failed to open a connection to the AppleSMC driver
        case FailedToOpen

        /// This SMC key is not valid on this machine
        case KeyNotFound(code: String)

        /// Requires root privileges
        case NotPrivileged

        /// Fan speed must be > 0 && <= fanMaxSpeed
        case UnsafeFanSpeed

        /// https://developer.apple.com/library/mac/qa/qa1075/_index.html
        ///
        /// - parameter kIOReturn: I/O Kit error code
        /// - parameter SMCResult: SMC specific return code
        case Unknown(kIOReturn: kern_return_t, SMCResult: UInt8)
    }

    /// Connection to the SMC driver
    private static var connection: io_connect_t = 0

    /// Open connection to the SMC driver. This must be done first before any
    /// other calls
    public static func open() throws {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("AppleSMC"))

        if service == 0 { throw Error.DriverNotFound }

        let result = IOServiceOpen(service, mach_task_self_, 0,
                                   &SMCKit.connection)
        IOObjectRelease(service)

        if result != kIOReturnSuccess { throw Error.FailedToOpen }
    }

    /// Close connection to the SMC driver
    public static func close() -> Bool {
        let result = IOServiceClose(SMCKit.connection)
        return result == kIOReturnSuccess ? true : false
    }

    /// Get information about a key
    public static func keyInformation(key: FourCharCode) throws -> DataType {
        var inputStruct = SMCParamStruct()

        inputStruct.key = key
        inputStruct.data8 = SMCParamStruct.Selector.kSMCGetKeyInfo.rawValue

        let outputStruct = try callDriver(&inputStruct)

        return DataType(type: outputStruct.keyInfo.dataType,
                        size: outputStruct.keyInfo.dataSize)
    }

    /// Get information about the key at index
    public static func keyInformationAtIndex(index: Int) throws ->
                                                                  FourCharCode {
        var inputStruct = SMCParamStruct()

        inputStruct.data8 = SMCParamStruct.Selector.kSMCGetKeyFromIndex.rawValue
        inputStruct.data32 = UInt32(index)

        let outputStruct = try callDriver(&inputStruct)

        return outputStruct.key
    }

    /// Read data of a key
    public static func readData(key: SMCKey) throws -> SMCBytes {
        var inputStruct = SMCParamStruct()

        inputStruct.key = key.code
        inputStruct.keyInfo.dataSize = UInt32(key.info.size)
        inputStruct.data8 = SMCParamStruct.Selector.kSMCReadKey.rawValue

        let outputStruct = try callDriver(&inputStruct)

        return outputStruct.bytes
    }

    /// Write data for a key
    public static func writeData(key: SMCKey, data: SMCBytes) throws {
        var inputStruct = SMCParamStruct()

        inputStruct.key = key.code
        inputStruct.bytes = data
        inputStruct.keyInfo.dataSize = UInt32(key.info.size)
        inputStruct.data8 = SMCParamStruct.Selector.kSMCWriteKey.rawValue

        try callDriver(&inputStruct)
    }

    /// Make an actual call to the SMC driver
    public static func callDriver(inout inputStruct: SMCParamStruct,
                        selector: SMCParamStruct.Selector = .kSMCHandleYPCEvent)
                                                      throws -> SMCParamStruct {
        assert(strideof(SMCParamStruct) == 80, "SMCParamStruct size is != 80")

        var outputStruct = SMCParamStruct()
        let inputStructSize = strideof(SMCParamStruct)
        var outputStructSize = strideof(SMCParamStruct)

        let result = IOConnectCallStructMethod(SMCKit.connection,
                                               UInt32(selector.rawValue),
                                               &inputStruct,
                                               inputStructSize,
                                               &outputStruct,
                                               &outputStructSize)

        switch (result, outputStruct.result) {
        case (kIOReturnSuccess, SMCParamStruct.Result.kSMCSuccess.rawValue):
            return outputStruct
        case (kIOReturnSuccess, SMCParamStruct.Result.kSMCKeyNotFound.rawValue):
            throw Error.KeyNotFound(code: inputStruct.key.toString())
        case (kIOReturnNotPrivileged, _):
            throw Error.NotPrivileged
        default:
            throw Error.Unknown(kIOReturn: result,
                                SMCResult: outputStruct.result)
        }
    }
}

//------------------------------------------------------------------------------
// MARK: General
//------------------------------------------------------------------------------

extension SMCKit {

    /// Get all valid SMC keys for this machine
    public static func allKeys() throws -> [SMCKey] {
        let count = try keyCount()
        var keys = [SMCKey]()

        for var i = 0; i < count; ++i {
            let key = try keyInformationAtIndex(i)
            let info = try keyInformation(key)
            keys.append(SMCKey(code: key, info: info))
        }

        return keys
    }

    /// Get the number of valid SMC keys for this machine
    public static func keyCount() throws -> Int {
        let key = SMCKey(code: FourCharCode(fromStaticString: "#KEY"),
            info: dataTypeUI32)

        let data = try readData(key)
        return Int(UInt32(fromBytes: (data.0, data.1, data.2, data.3)))
    }

    /// Is this key valid on this machine?
    public static func isKeyValid(code: FourCharCode) throws -> Bool {
        do {
            try keyInformation(code)
        } catch Error.KeyNotFound { return false }

        return true
    }
}

//------------------------------------------------------------------------------
// MARK: Temperature
//------------------------------------------------------------------------------

/// The list is NOT exhaustive. In addition, the names of the sensors may not be
/// mapped to the correct hardware component.
///
/// ### Sources
///
/// * powermetrics(1)
/// * https://www.apple.com/downloads/dashboard/status/istatpro.html
/// * https://github.com/hholtmann/smcFanControl
/// * https://github.com/jedda/OSX-Monitoring-Tools
/// * http://www.opensource.apple.com/source/net_snmp/
/// * http://www.parhelia.ch/blog/statics/k3_keys.html
public struct TemperatureSensors {
    /*
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
    */
    public static let AMBIENT_AIR_0 = TemperatureSensor(name: "AMBIENT_AIR_0",
                                   code: FourCharCode(fromStaticString: "TA0P"))
    public static let AMBIENT_AIR_1 = TemperatureSensor(name: "AMBIENT_AIR_1",
                                   code: FourCharCode(fromStaticString: "TA0P"))
    // Via powermetrics(1)
    public static let CPU_0_DIE = TemperatureSensor(name: "CPU_0_DIE",
                                   code: FourCharCode(fromStaticString: "TC0F"))
    public static let CPU_0_DIODE = TemperatureSensor(name: "CPU_0_DIODE",
                                   code: FourCharCode(fromStaticString: "TC0D"))
    public static let CPU_0_HEATSINK = TemperatureSensor(name: "CPU_0_HEATSINK",
                                   code: FourCharCode(fromStaticString: "TC0H"))
    public static let CPU_0_PROXIMITY =
                                      TemperatureSensor(name: "CPU_0_PROXIMITY",
                                   code: FourCharCode(fromStaticString: "TC0P"))
    public static let GPU_0_DIODE = TemperatureSensor(name: "GPU_0_DIODE",
                                   code: FourCharCode(fromStaticString: "TG0D"))
    public static let GPU_0_HEATSINK = TemperatureSensor(name: "GPU_0_HEATSINK",
                                   code: FourCharCode(fromStaticString: "TG0H"))

    public static let all = [AMBIENT_AIR_0, AMBIENT_AIR_1, CPU_0_DIE,
                             CPU_0_DIODE, CPU_0_PROXIMITY, GPU_0_DIODE,
                             GPU_0_HEATSINK]
}

public struct TemperatureSensor {
    let name: String
    let code: FourCharCode
}

public enum TemperatureUnit {
    case Celius
    case Fahrenheit
    case Kelvin

    public static func toFahrenheit(celius: Double) -> Double {
        // https://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (celius * 1.8) + 32
    }

    public static func toKelvin(celius: Double) -> Double {
        // https://en.wikipedia.org/wiki/Kelvin
        return celius + 273.15
    }
}

extension SMCKit {

    public static func allKnownTemperatureSensors() throws ->
                                                           [TemperatureSensor] {
        var sensors = [TemperatureSensor]()

        for sensor in TemperatureSensors.all {
            do {
                if try isKeyValid(sensor.code) { sensors.append(sensor) }
            } catch Error.KeyNotFound { /* Do nothing */ }
        }

        return sensors
    }

    public static func allUnknownTemperatureSensors() throws -> [SMCKey] {
        let keys = try allKeys()
        return keys.filter { $0.code.toString().hasPrefix("T") &&
                             $0.info == dataTypeSP78 }
    }

    /// Get current temperature of a sensor
    public static func temperature(sensorCode: FourCharCode,
                             unit: TemperatureUnit = .Celius) throws -> Double {
        let data = try readData(SMCKey(code: sensorCode, info: dataTypeSP78))

        let temperatureInCelius = Double(fromSP78: (data.0, data.1))

        switch unit {
        case .Celius:
            return temperatureInCelius
        case .Fahrenheit:
            return TemperatureUnit.toFahrenheit(temperatureInCelius)
        case .Kelvin:
            return TemperatureUnit.toKelvin(temperatureInCelius)
        }
    }
}

//------------------------------------------------------------------------------
// MARK: Fan
//------------------------------------------------------------------------------

public struct Fan {
    public let id: Int
    public let name: String
    public let minSpeed: Int
    public let maxSpeed: Int
}

extension SMCKit {

    public static func allFans() throws -> [Fan] {
        let count = try fanCount()
        var fans = [Fan]()

        for var i = 0; i < count; ++i {
            let name = try fanName(i)
            let minSpeed = try fanMinSpeed(i)
            let maxSpeed = try fanMaxSpeed(i)
            fans.append(Fan(id: i, name: name, minSpeed: minSpeed,
                                               maxSpeed: maxSpeed))
        }

        return fans
    }

    /// Number of fans this machine has. All Intel based Macs, except for the
    /// 2015 MacBook (8,1), have at least 1
    public static func fanCount() throws -> Int {
        let key = SMCKey(code: FourCharCode(fromStaticString: "FNum"),
                                            info: dataTypeUI8)

        let data = try readData(key)
        return Int(data.0)
    }

    public static func fanName(id: Int) throws -> String {
        let key = SMCKey(code: FourCharCode(fromString: "F\(id)ID"),
                                            info: dataTypeFDS)
        let data = try readData(key)

        // The last 12 bytes of '{fds' data type, a custom struct defined by the
        // AppleSMC.kext that is 16 bytes, contains the fan name
        let c1  = String(UnicodeScalar(data.4))
        let c2  = String(UnicodeScalar(data.5))
        let c3  = String(UnicodeScalar(data.6))
        let c4  = String(UnicodeScalar(data.7))
        let c5  = String(UnicodeScalar(data.8))
        let c6  = String(UnicodeScalar(data.9))
        let c7  = String(UnicodeScalar(data.10))
        let c8  = String(UnicodeScalar(data.11))
        let c9  = String(UnicodeScalar(data.12))
        let c10 = String(UnicodeScalar(data.13))
        let c11 = String(UnicodeScalar(data.14))
        let c12 = String(UnicodeScalar(data.15))

        let name = c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 + c11 + c12

        let characterSet = NSCharacterSet.whitespaceCharacterSet()
        return name.stringByTrimmingCharactersInSet(characterSet)
    }

    public static func fanCurrentSpeed(id: Int) throws -> Int {
        let key = SMCKey(code: FourCharCode(fromString: "F\(id)Ac"),
                                            info: dataTypeFPE2)

        let data = try readData(key)
        return Int(fromFPE2: (data.0, data.1))
    }

    public static func fanMinSpeed(id: Int) throws -> Int {
        let key = SMCKey(code: FourCharCode(fromString: "F\(id)Mn"),
                                            info: dataTypeFPE2)

        let data = try readData(key)
        return Int(fromFPE2: (data.0, data.1))
    }

    public static func fanMaxSpeed(id: Int) throws -> Int {
        let key = SMCKey(code: FourCharCode(fromString: "F\(id)Mx"),
                                            info: dataTypeFPE2)

        let data = try readData(key)
        return Int(fromFPE2: (data.0, data.1))
    }

    /// Requires root privileges. By minimum we mean that OS X can interject and
    /// raise the fan speed if needed, however it will not go below this.
    ///
    /// WARNING: You are playing with hardware here, BE CAREFUL.
    public static func fanSetMinSpeed(id: Int, speed: Int) throws {
        let maxSpeed = try fanMaxSpeed(id)
        if speed <= 0 || speed > maxSpeed { throw Error.UnsafeFanSpeed }

        let data = speed.toFPE2()
        let bytes = (data.0, data.1, UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                     UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                     UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                     UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                     UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                     UInt8(0), UInt8(0))

        let key = SMCKey(code: FourCharCode(fromString: "F\(id)Mn"),
                         info: dataTypeFPE2)

        try writeData(key, data: bytes)
    }
}

//------------------------------------------------------------------------------
// MARK: Miscellaneous
//------------------------------------------------------------------------------

public struct batteryInfo {
    let batteryCount: Int
    let isACPresent: Bool
    let isBatteryPowered: Bool
    let isBatteryOk: Bool
    let isCharging: Bool
}

extension SMCKit {

    public static func isOpticalDiskDriveFull() throws -> Bool {
        let key = SMCKey(code: FourCharCode(fromStaticString: "MSDI"),
                         info: dataTypeFLAG)

        let data = try readData(key)
        return Bool(fromByte: data.0)
    }

    public static func batteryInformation() throws -> batteryInfo {
        let batteryCountKey =
         SMCKey(code: FourCharCode(fromStaticString: "BNum"), info: dataTypeUI8)
        let batteryPoweredKey =
        SMCKey(code: FourCharCode(fromStaticString: "BATP"), info: dataTypeFLAG)
        let batteryInfoKey =
         SMCKey(code: FourCharCode(fromStaticString: "BSIn"), info: dataTypeUI8)

        let batteryCountData = try readData(batteryCountKey)
        let batteryCount = Int(batteryCountData.0)

        let isBatteryPoweredData = try readData(batteryPoweredKey)
        let isBatteryPowered = Bool(fromByte: isBatteryPoweredData.0)

        let batteryInfoData = try readData(batteryInfoKey)
        let isCharging = batteryInfoData.0 & 1 == 1 ? true : false
        let isACPresent = (batteryInfoData.0 >> 1) & 1 == 1 ? true : false
        let isBatteryOk = (batteryInfoData.0 >> 6) & 1 == 1 ? true : false

        return batteryInfo(batteryCount: batteryCount, isACPresent: isACPresent,
                           isBatteryPowered: isBatteryPowered,
                           isBatteryOk: isBatteryOk,
                           isCharging: isCharging)
    }
}
