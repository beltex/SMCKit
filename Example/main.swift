//
// Simple example usage of SMCKit. Prints machine status: temperatures, fans,
// battery, power, misc.
//
// main.swift
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

import SMCKit

var smc = SMC()

if (smc.open() != kIOReturnSuccess) {
    println("ERROR: Failed to open connection to SMC")
    exit(-1)
}
println("// MACHINE STATUS")


println("\n-- TEMPERATURE --")
let temperatureSensors = smc.getAllValidTemperatureKeys()

for key in temperatureSensors {
    let temperatureSensorName = SMC.Temperature.allValues[key]!
    let temperature           = smc.getTemperature(key).tmp
    
    println("\(temperatureSensorName)\n\t\(temperature)°C")
}


println("\n-- FAN --")
let numberOfFans = smc.getNumFans().numFans

for var i: UInt = 0; i < numberOfFans; ++i {
    let name    = smc.getFanName(i).name
    let current = smc.getFanRPM(i).rpm
    let min     = smc.getFanMinRPM(i).rpm
    let max     = smc.getFanMaxRPM(i).rpm

    println(name)
    println("\tCurrent:  \(current) RPM")
    println("\tMin:      \(min) RPM")
    println("\tMax:      \(max) RPM")
}


println("\n-- BATTERY & POWER --")
println("AC Present:          \(smc.isACPresent().flag)")
println("Battery Powered:     \(smc.isBatteryPowered().flag)")
println("Charging:            \(smc.isCharging().flag)")
println("Battery Ok:          \(smc.isBatteryOk().flag)")
println("Max # of Batteries:  \(smc.maxNumberBatteries().count)")


println("\n-- MISC --")
println("Disc in ODD:         \(smc.isOpticalDiskDriveFull().flag)")


smc.close()