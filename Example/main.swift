/*
* Simple example usage of SMCKit. Prints machine status: temperatures, fans,
* power, misc.
*
* main.swift
* SMCKit
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

import SMCKit


let smc = SMC()

if (smc.open() != kIOReturnSuccess) {
    println("ERROR: Failed to open connection to SMC")
    exit(-1)
}
println("// MACHINE STATUS")


println("\n-- TEMPERATURE --")
let temperatureSensors = smc.getAllValidTMPKeys()


for (key, name) in temperatureSensors {
    let temperature = smc.getTMP(SMC.TMP.allValues[name]!).tmp
    
    println("\(name)\n\t\(temperature)°C")
}


println("\n-- FAN --")
let numberOfFans = smc.getNumFans().numFans

for var i : UInt = 0; i < numberOfFans; ++i {
    let fanName = smc.getFanName(i).name
    let fanRPM  = smc.getFanRPM(i).rpm
    
    println("\(fanName)\n\t\(fanRPM) RPM")
}


println("\n-- POWER --")
println("AC Present:       \(smc.isACPresent().flag)")
println("Battery Powered:  \(smc.isBatteryPowered().flag)")
println("Charging:         \(smc.isCharging().flag)")
println("Battery Ok:       \(smc.isBatteryOk().flag)")


println("\n-- MISC --")
println("Disc in ODD:      \(smc.isOpticalDiskDriveFull().flag)")


smc.close()