//
// OS X SMC Tool
//
// SMCKitTool/main.swift
// SMCKit
//
// The MIT License
//
// Copyright (C) 2015  beltex <http://beltex.github.io>
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

// Not using the following as frameworks, but as source files. See README.md for
// more
//import CommandLine
//import SMCKit

//------------------------------------------------------------------------------
// MARK: GLOBALS
//------------------------------------------------------------------------------

let SMCKitToolVersion     = "0.0.1"
let maxTemperatureCelsius = 128.0

//------------------------------------------------------------------------------
// MARK: ENUMS
//------------------------------------------------------------------------------

enum ANSIColor: String {
    case Off    = "\u{001B}[0;0m"
    case Red    = "\u{001B}[0;31m"
    case Green  = "\u{001B}[0;32m"
    case Yellow = "\u{001B}[0;33m"
}

//------------------------------------------------------------------------------
// MARK: COMMAND LINE INTERFACE
//------------------------------------------------------------------------------

let CLIColorOption       = BoolOption(shortFlag: "c", longFlag: "color",
                                helpMessage: "Colorize output where applicable")
let CLIDisplayKeysOption = BoolOption(shortFlag: "d", longFlag: "display-keys",
        helpMessage: "Show SMC keys (FourCC) when printing temperature sensors")
let CLIFanOption         = BoolOption(shortFlag: "f", longFlag: "fan",
                         helpMessage: "Show Show the machines fan speeds (RPM)")
let CLIHelpOption        = BoolOption(shortFlag: "h", longFlag: "help",
                                      helpMessage: "Show the list of options")
let CLICheckKeyOption    = StringOption(shortFlag: "k", longFlag: "check-key",
                                        required: false,
            helpMessage: "Check if a FourCC is a valid SMC key on this machine")
let CLIMiscOption        = BoolOption(shortFlag: "m", longFlag: "misc",
                        helpMessage: "Show misc information about this machine")
let CLIFanIdOption       = IntOption(shortFlag: "n", longFlag: "fan-id",
                                     required: false,
   helpMessage: "The id (number - starts from 0) of the fan whose speed to set")
let CLIPowerOption       = BoolOption(shortFlag: "p", longFlag: "power",
               helpMessage: "Show power related information about this machine")
let CLIFanSpeedOption    = IntOption(shortFlag: "s", longFlag: "fan-speed",
                                   required: false,
                           helpMessage: "The min speed (RPM) of the fan to set")
let CLITemperatureOption = BoolOption(shortFlag: "t", longFlag: "temperature",
            helpMessage: "Show the list of temperature sensors on this machine")
let CLIVersionOption     = BoolOption(shortFlag: "v", longFlag: "version",
                                   helpMessage: "Show smckit version")
let CLIWarnOption        = BoolOption(shortFlag: "w", longFlag: "warn",
      helpMessage: "Show warning levels for temperature sensors and fan speeds")

// Keep this list sorted by short flag. This will be the order that it is
// printed when printUsage() ('--help') is called
let CLIOptions = [CLIColorOption,
                  CLIDisplayKeysOption,
                  CLIFanOption,
                  CLIHelpOption,
                  CLICheckKeyOption,
                  CLIMiscOption,
                  CLIFanIdOption,
                  CLIFanSpeedOption,
                  CLIPowerOption,
                  CLITemperatureOption,
                  CLIVersionOption,
                  CLIWarnOption]

let CLI = CommandLine()
CLI.addOptions(CLIOptions)

do {
    try CLI.parse()
} catch {
    CLI.printUsage(error)
    exit(EX_USAGE)
}

// Give precedence to help flag
if CLIHelpOption.value {
    CLI.printUsage()
    exit(EX_USAGE)
}
else if CLIVersionOption.value {
    print(SMCKitToolVersion)
    exit(EX_USAGE)
}

let isSetNonBoolOptions = CLIOptions.filter { $0.isSet == true &&
                                              $0 as? BoolOption == nil }
let isSetBoolOptions = CLIOptions.filter { $0 as? BoolOption != nil }
                                 .map    { $0 as! BoolOption        }
                                 .filter { $0.value == true         }

//------------------------------------------------------------------------------
// MARK: FUNCTIONS
//------------------------------------------------------------------------------

func warningLevel(value: Double, maxValue: Double) -> (name: String,
                                                       color: ANSIColor) {
    let percentage = value / maxValue

    switch percentage {
        case 0...0.45:
            return ("Normal", ANSIColor.Green)
        case 0.45...0.75:
            return ("Danger", ANSIColor.Yellow)
        default:
            return ("Crisis", ANSIColor.Red)
    }
}

func colorBoolOutput(value: Bool) -> String {
    let color: ANSIColor
    if CLIColorOption.value { color = value ? ANSIColor.Green : ANSIColor.Red }
    else                    { color = ANSIColor.Off }

    return "\(color.rawValue)\(value)\(ANSIColor.Off.rawValue)"
}

func printTemperatureInformation() {
    print("-- TEMPERATURE --")
    let temperatureSensors = smc.getAllValidTemperatureKeys()

    for key in temperatureSensors {
        let temperatureSensorName = SMC.Temperature.allValues[key]!
        let temperature           = smc.getTemperature(key).tmp

        let warning = warningLevel(temperature, maxValue: maxTemperatureCelsius)
        let level   = CLIWarnOption.value ? "(\(warning.name))" : ""
        let color   = CLIColorOption.value ? warning.color : ANSIColor.Off

        let smcKey  = CLIDisplayKeysOption.value ? "(\(key.rawValue))" : ""

        print("\(temperatureSensorName) \(smcKey)")
        print("\t\(color.rawValue)\(temperature)°C \(level)" +
                                                    "\(ANSIColor.Off.rawValue)")
    }
}

func printFanInformation() {
    print("-- FAN --")
    let fanCount = smc.getNumFans().numFans

    if fanCount == 0 { print("** Fanless **") }
    else {
        for var i: UInt = 0; i < fanCount; ++i {
            let name    = smc.getFanName(i).name
            let current = smc.getFanRPM(i).rpm
            let min     = smc.getFanMinRPM(i).rpm
            let max     = smc.getFanMaxRPM(i).rpm

            let warning = warningLevel(Double(current), maxValue: Double(max))
            let level   = CLIWarnOption.value ? "(\(warning.name))" : ""
            let color   = CLIColorOption.value ? warning.color : ANSIColor.Off

            print("[id \(i)] \(name)")
            print("\tCurrent:  \(color.rawValue)\(current) RPM \(level)" +
                                                    "\(ANSIColor.Off.rawValue)")
            print("\tMin:      \(min) RPM")
            print("\tMax:      \(max) RPM")
        }
    }
}

func printPowerInformation() {
    print("-- POWER --")
    print("AC Present:       \(colorBoolOutput(smc.isACPresent().flag))")
    print("Battery Powered:  \(colorBoolOutput(smc.isBatteryPowered().flag))")
    print("Charging:         \(colorBoolOutput(smc.isCharging().flag))")
    print("Battery Ok:       \(colorBoolOutput(smc.isBatteryOk().flag))")
    print("Max Batteries:    \(smc.maxNumberBatteries().count)")
}

func printMiscInformation() {
    print("-- MISC --")

    let ODDStatus = smc.isOpticalDiskDriveFull().flag
    print("Disc in ODD:      \(colorBoolOutput(ODDStatus))")
}

func printAll() {
    printTemperatureInformation()
    printFanInformation()
    printPowerInformation()
    printMiscInformation()
}

func checkKey(key: String) {
    if smc.isKeyValid(key).valid { print("VALID")   }
    else                         { print("INVALID") }
}

func setMinFanSpeed(fanNumber: Int, fanSpeed: Int) {
    let result = smc.setFanMinRPM(UInt(fanNumber), RPM: UInt(fanSpeed))

    if result.result { print("SUCCESS") }
    else if result.IOReturn == kIOReturnNotPrivileged {
        print("This operation must be invoked as the superuser")
    }
    else if result.IOReturn == kIOReturnBadArgument {
        let maxSpeed = smc.getFanMaxRPM(UInt(fanNumber)).rpm
        print("Invalid fan speed. Must be <= max fan speed (\(maxSpeed))")
    }
    else if result.kSMC == SMC.kSMC.kSMCKeyNotFound.rawValue {
        print("This machine has no fan #\(fanNumber)")
    }
    else {
        print("FAILED: IOKit(\(result.IOReturn)), SMC(\(result.kSMC))")
    }
}

//------------------------------------------------------------------------------
// MARK: MAIN
//------------------------------------------------------------------------------

var smc = SMC()
if smc.open() != kIOReturnSuccess {
    print("ERROR: Failed to open connection to SMC")
    exit(EX_UNAVAILABLE)
}


// FIXME: This is bad, need a better way. Need changes in CommandLine lib
if Process.arguments.count == 1 ||
   (isSetNonBoolOptions.count == 0 &&
    isSetBoolOptions.filter { switch $0.shortFlag {
                                  case "c", "d", "w": return true
                                  default           : return false
                              }}.count == isSetBoolOptions.count) {
    printAll()
}


if CLIFanIdOption.isSet && CLIFanSpeedOption.isSet {
    setMinFanSpeed(CLIFanIdOption.value!, fanSpeed: CLIFanSpeedOption.value!)
}
else if CLIFanSpeedOption.isSet != CLIFanIdOption.isSet {   // XOR
    print("Usage: Must set fan number (-n) AND fan speed (-s)")
}

if let key = CLICheckKeyOption.value { checkKey(key) }

if CLITemperatureOption.value { printTemperatureInformation() }
if CLIFanOption.value         { printFanInformation()         }
if CLIPowerOption.value       { printPowerInformation()       }
if CLIMiscOption.value        { printMiscInformation()        }

smc.close()
