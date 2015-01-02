/*
* SMCKitTests.swift
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

import Cocoa
import XCTest
import SMCKit

/*
TODO: What do we test exactly? We can't check for return values, like
      temperature or fan RPM as we can't validate them. We also don't have a
      master list of what each Mac has (which fans, sensors, etc.) to check
      against.

      - Could have tests that are model specific?
      - We can test that the calls don't fail, but not if the return values are
        correct
      - Some methods can be cross checked through I/O Kit calls, for example
        battery/power related methods (AppleSmartBattery :))
      - Don't want to have any tests that could intermittently fail, like TMP
        checks with a tolerance? That 0 K is not returned for example :).
*/
class SMCKitTests: XCTestCase {
    
    var smc = SMC()
    
    // TODO: Setup once?
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
        // TODO: If this fails no test should run
        smc.open()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of
        // each test method in the class.
        smc.close()
        
        super.tearDown()
    }
    
    func testOpenConnectionTwice() {
        XCTAssertNotEqual(smc.open(), kIOReturnSuccess)
    }
    
    func testCloseConnectionTwice() {
        XCTAssertEqual(smc.close(), kIOReturnSuccess)
        XCTAssertNotEqual(smc.close(), kIOReturnSuccess)
        
        // Test that we can reopen and things still work
        smc.open()
        XCTAssertGreaterThanOrEqual(smc.getNumFans().numFans, UInt(1))
        XCTAssertEqual(smc.close(), kIOReturnSuccess)
    }
    
    func testTemperatureValues() {
        let temperatureSensors = smc.getAllValidTemperatureKeys()
        
        for sensor in temperatureSensors {
            let temperature = smc.getTemperature(sensor).tmp
            
            XCTAssertGreaterThan(temperature, -128.0)
            XCTAssertLessThan(temperature, 128.0)
        }
    }
    
    func testGetNumberFans() {
        // All Macs until now have atleast 1 fan
        
        let result = smc.getNumFans()
        
        XCTAssertGreaterThanOrEqual(result.numFans, UInt(1))
        
        // This is a loose value on purpose
        XCTAssertLessThanOrEqual(result.numFans, UInt(20))
    }
    
    func testIsKeyValid() {
        XCTAssertFalse(smc.isKeyValid("").valid)
        XCTAssertFalse(smc.isKeyValid("Vi").valid)
        XCTAssertFalse(smc.isKeyValid("Vim").valid)
        XCTAssertFalse(smc.isKeyValid("What is this new devilry?").valid)
    }
    
    func testODD() {
        // Test that isOpticalDiskDriveFull() returns false when there is no 
        // ODD. We can do this by cross checking the I/O Reg
        // IOAHCISerialATAPI
        // TODO: What if its an Apple USB SuperDrive?
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: TESTS - BATTERY/POWER
    //--------------------------------------------------------------------------
    
    
    func testBatteryPowerMethods() {
        var isLaptop    = false
        var ASPCharging = false
        var ASPCharged  = false
        
        // Check if machine is a laptop - if it is, we use the service to cross
        // check our values
        // TODO: Simplify I/O Kit calls here - can do it in a single call
        // TODO: What if its a MacBook with a removable battery and its out?
        var service = IOServiceGetMatchingService(kIOMasterPortDefault,
               IOServiceNameMatching("AppleSmartBattery").takeUnretainedValue())
        if (service != 0) {
            isLaptop = true
            
            // Getting these values to cross ref
            var prop = IORegistryEntryCreateCFProperty(service, "IsCharging",
                                                       kCFAllocatorDefault,
                                                       UInt32(kNilOptions))
            
            ASPCharging = prop.takeUnretainedValue() as Int == 1 ? true : false
            
            
            prop = IORegistryEntryCreateCFProperty(service, "FullyCharged",
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
            
            ASPCharged = prop.takeUnretainedValue() as Int == 1 ? true : false
        }
        
        
        let batteryPowered = smc.isBatteryPowered().flag
        let batteryOk      = smc.isBatteryOk().flag
        let ACPresent      = smc.isACPresent().flag
        let charging       = smc.isCharging().flag
        let numBatteries   = smc.maxNumberBatteries().count
        
        if (isLaptop) {
            // TODO: Is there any Mac that supports more then 1?
            XCTAssertEqual(numBatteries, UInt(1))
            
            /*
            Yeah, truth tables!... :)
            
            Note two specific cases we allow. First is to be battery powered and
            be fully charged. This could be true for a short period of time so
            we allow it. Second, much rarer occurrence, is AC powered and not
            charging or charged. This could be the case if the battery is pulled
            out.
            TODO: Though if the battery is out, AppleSmartBattery may not
                  show up...
            
            Can query WolframAlpha with "truth table" prefix to see it.
            
            Origin: (A ^ B) && ((B && !C) ^ (B <=> C)) && ((C ^ D) ^ (!C && !D))    

            CNF:    (!A || !B) && (A || B) && (B || !C) && (!C || !D)
            
            http://www.wolframalpha.com
            */
            let A = batteryPowered
            let B = ACPresent
            let C = charging && ASPCharging
            let D = ASPCharged
            
            XCTAssertTrue((!A || !B) && (A || B) && (B || !C) && (!C || !D))
        }
        else {
            XCTAssertFalse(batteryOk)
            XCTAssertFalse(batteryPowered)
            XCTAssertFalse(charging)
            XCTAssertTrue(ACPresent)
            XCTAssertEqual(numBatteries, UInt(0))
        }
        
        
        // TODO: Make sure this is called, even if tests above fail
        IOObjectRelease(service)
    }
}
