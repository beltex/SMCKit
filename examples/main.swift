/*
* Simple sample test client
*
* main.swift
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

var smc = SMC()

// Open a connection to the SMC
if (smc.openSMC() == kIOReturnSuccess) {
    var result = smc.getTMP(SMC.TMP.CPU_0_DIODE)
    
    println("CPU 0 Diode Temperature: \(result.tmp)°C")
    println("IO Return Code: \(result.IOReturn)")
    println("SMC Return Code: \(result.kSMC)")
    
    // Make sure to close the connection
    smc.closeSMC()
}
else {
    println("ERROR: Failed to open connection to SMC")
}