//
// OS X Apple System Management Controller (SMC) Tool
//
// SMCKitTool/main.swift
// SMCKit
//
// The MIT License
//
// Copyright (C) 2015-2017  beltex <https://beltex.github.io>
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

import Darwin

// Not using the following as frameworks, but as source files. See README.md for
// more
//import CommandLine
//import SMCKit

//------------------------------------------------------------------------------
// MARK: Globals
//------------------------------------------------------------------------------

let SMCKitToolVersion     = "0.2.0-dev"
let maxTemperatureCelsius = 128.0

//------------------------------------------------------------------------------
// MARK: Enums
//------------------------------------------------------------------------------

enum ANSIColor: String {
    case Off    = "\u{001B}[0;0m"
    case Red    = "\u{001B}[0;31m"
    case Green  = "\u{001B}[0;32m"
    case Yellow = "\u{001B}[0;33m"
    case Blue   = "\u{001B}[0;34m"
}

//------------------------------------------------------------------------------
// MARK: CLI
//------------------------------------------------------------------------------

let CLIColorOption       = BoolOption(shortFlag: "c", longFlag: "color",
                                helpMessage: "Colorize output where applicable")
let CLIDisplayKeysOption = BoolOption(shortFlag: "d", longFlag: "display-keys",
        helpMessage: "Show SMC keys (FourCC) when printing temperature sensors")
let CLIFanOption         = BoolOption(shortFlag: "f", longFlag: "fan",
                         helpMessage: "Show fan speeds (RPM)")
let CLIHelpOption        = BoolOption(shortFlag: "h", longFlag: "help",
                                      helpMessage: "Show the list of options")
let CLICheckKeyOption    = StringOption(shortFlag: "k", longFlag: "check-key",
            helpMessage: "Check if a FourCC is a valid SMC key on this machine")
let CLIMiscOption        = BoolOption(shortFlag: "m", longFlag: "misc",
                        helpMessage: "Show misc information")
let CLIFanIdOption       = IntOption(shortFlag: "n", longFlag: "fan-id",
   helpMessage: "The id (number - starts from 0) of the fan whose speed to set")
let CLIPowerOption       = BoolOption(shortFlag: "p", longFlag: "power",
               helpMessage: "Show power related information")
let CLIFanSpeedOption    = IntOption(shortFlag: "s", longFlag: "fan-speed",
                           helpMessage: "The min speed (RPM) of the fan to set")
let CLITemperatureOption = BoolOption(shortFlag: "t", longFlag: "temperature",
      helpMessage: "Show temperature sensors whose hardware mapping is known")
let CLIUnknownTemperatureOption = BoolOption(shortFlag: "u",
                                        longFlag: "unknown-temperature-sensors",
      helpMessage: "Show temperature sensors whose hardware mapping is unknown")
let CLIVersionOption     = BoolOption(shortFlag: "v", longFlag: "version",
                                   helpMessage: "Show SMCKitTool version")
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
                  CLIUnknownTemperatureOption,
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
if CLIHelpOption.wasSet {
    CLI.printUsage()
    exit(EX_OK)
} else if CLIVersionOption.wasSet {
    print(SMCKitToolVersion)
    exit(EX_OK)
}

//------------------------------------------------------------------------------
// MARK: Functions
//------------------------------------------------------------------------------

func warningLevel(value: Double, maxValue: Double) -> (name: String,
                                                       color: ANSIColor) {
    let percentage = value / maxValue

    switch percentage {
    // TODO: Is this safe? Rather, is this the best way to go about this?
    case -Double.infinity...0: return ("Cool", ANSIColor.Blue)
    case 0...0.45:             return ("Nominal", ANSIColor.Green)
    case 0.45...0.75:          return ("Danger", ANSIColor.Yellow)
    default:                   return ("Crisis", ANSIColor.Red)
    }
}

func colorBoolOutput(value: Bool) -> String {
    let color: ANSIColor
    if CLIColorOption.wasSet { color = value ? ANSIColor.Green : ANSIColor.Red }
    else                     { color = ANSIColor.Off }

    return "\(color.rawValue)\(value)\(ANSIColor.Off.rawValue)"
}

func printTemperatureInformation(known: Bool = true) {
    print("-- Temperature --")

    let sensors: [TemperatureSensor]
    do {
        if known {
            sensors = try SMCKit.allKnownTemperatureSensors().sorted
                                                           { $0.name < $1.name }
        } else {
            sensors = try SMCKit.allUnknownTemperatureSensors()
        }

    } catch {
        print(error)
        return
    }


    let sensorWithLongestName = sensors.max { $0.name.characters.count <
                                                     $1.name.characters.count }

    guard let longestSensorNameCount = sensorWithLongestName?.name.characters.count else {
        print("No temperature sensors found")
        return
    }


    for sensor in sensors {
        let padding = String(repeating: " ",
                             count: longestSensorNameCount - sensor.name.characters.count)

        let smcKey  = CLIDisplayKeysOption.wasSet ? "(\(sensor.code.toString()))" : ""
        print("\(sensor.name + padding)   \(smcKey)  ", terminator: "")


        guard let temperature = try? SMCKit.temperature(sensor.code) else {
            print("NA")
            return
        }

        let warning = warningLevel(value: temperature, maxValue: maxTemperatureCelsius)
        let level   = CLIWarnOption.wasSet ? "(\(warning.name))" : ""
        let color   = CLIColorOption.wasSet ? warning.color : ANSIColor.Off

        print("\(color.rawValue)\(temperature)°C \(level)" +
              "\(ANSIColor.Off.rawValue)")
    }
}

func printFanInformation() {
    print("-- Fan --")

    let allFans: [Fan]
    do {
        allFans = try SMCKit.allFans()
    } catch {
        print(error)
        return
    }

    if allFans.count == 0 { print("No fans found") }

    for fan in allFans {
        print("[id \(fan.id)] \(fan.name)")
        print("\tMin:      \(fan.minSpeed) RPM")
        print("\tMax:      \(fan.maxSpeed) RPM")

        guard let currentSpeed = try? SMCKit.fanCurrentSpeed(fan.id) else {
            print("\tCurrent:  NA")
            return
        }

        let warning = warningLevel(value: Double(currentSpeed),
                                   maxValue: Double(fan.maxSpeed))
        let level = CLIWarnOption.wasSet ? "(\(warning.name))" : ""
        let color = CLIColorOption.wasSet ? warning.color : ANSIColor.Off
        print("\tCurrent:  \(color.rawValue)\(currentSpeed) RPM \(level)" +
                                                    "\(ANSIColor.Off.rawValue)")
    }
}

func printPowerInformation() {
    let information: batteryInfo
    do {
        information = try SMCKit.batteryInformation()
    } catch {
        print(error)
        return
    }

    print("-- Power --")
    print("AC Present:       \(colorBoolOutput(value: information.isACPresent))")
    print("Battery Powered:  \(colorBoolOutput(value: information.isBatteryPowered))")
    print("Charging:         \(colorBoolOutput(value: information.isCharging))")
    print("Battery Ok:       \(colorBoolOutput(value: information.isBatteryOk))")
    print("Battery Count:    \(information.batteryCount)")
}

func printMiscInformation() {
    print("-- Misc --")

    let ODDStatus: Bool
    do {
        ODDStatus = try SMCKit.isOpticalDiskDriveFull()
    } catch SMCKit.SMCError.keyNotFound { ODDStatus = false }
      catch {
        print(error)
        return
    }

    print("Disc in ODD:      \(colorBoolOutput(value: ODDStatus))")
}

func printAll() {
    printTemperatureInformation()
    printFanInformation()
    printPowerInformation()
    printMiscInformation()
}

func checkKey(key: String) {
    if key.characters.count != 4 {
        print("Must be a FourCC (four-character code)")
        return
    }

    do {
        let isValid = try SMCKit.isKeyFound(FourCharCode(fromString: key))
        let answer = isValid ? "valid" : "invalid"

        print("\(key) is a \(answer) SMC key on this machine")
    } catch { print(error) }
}

func setMinFanSpeed(fanId: Int, fanSpeed: Int) {
    do {
        let fan = try SMCKit.fan(fanId)
        let currentSpeed = try SMCKit.fanCurrentSpeed(fanId)

        try SMCKit.fanSetMinSpeed(fanId, speed: fanSpeed)

        print("Min fan speed set successfully")
        print("[id \(fan.id)] \(fan.name)")
        print("\tMin (Previous):  \(fan.minSpeed) RPM")
        print("\tMin (Target):    \(fanSpeed) RPM")
        print("\tCurrent:         \(currentSpeed) RPM")
    } catch SMCKit.SMCError.keyNotFound {
        print("This machine has no fan with id \(fanId)")
    } catch SMCKit.SMCError.notPrivileged {
        print("This operation must be invoked as the superuser")
    } catch SMCKit.SMCError.unsafeFanSpeed {
        print("Invalid fan speed. Must be <= max fan speed")
    } catch {
        print(error)
    }
}

//------------------------------------------------------------------------------
// MARK: MAIN
//------------------------------------------------------------------------------

do {
    try SMCKit.open()
} catch {
    print("Failed to open a connection to the SMC")
    exit(EX_UNAVAILABLE)
}

let wasSetOptions = CLIOptions.filter { $0.wasSet }

// Want to check that only a combination of the following flags is passed for
// printAll to occur
let printAllOptionsCount = wasSetOptions.filter {
    guard let shortFlag = $0.shortFlag else { return false }

    switch shortFlag {
    case "c", "d", "w": return true
    default           : return false
    }
}.count

if printAllOptionsCount == wasSetOptions.count { printAll() }


if let fanId = CLIFanIdOption.value, let fanSpeed = CLIFanSpeedOption.value {
    setMinFanSpeed(fanId: fanId, fanSpeed: fanSpeed)
}
else if CLIFanIdOption.wasSet != CLIFanSpeedOption.wasSet {
    print("Usage: Must set fan number (-n) AND fan speed (-s)")
}


if let key = CLICheckKeyOption.value { checkKey(key: key) }

if CLITemperatureOption.wasSet        { printTemperatureInformation() }
if CLIUnknownTemperatureOption.wasSet { printTemperatureInformation(known: false) }
if CLIFanOption.wasSet                { printFanInformation()         }
if CLIPowerOption.wasSet              { printPowerInformation()       }
if CLIMiscOption.wasSet               { printMiscInformation()        }

SMCKit.close()
