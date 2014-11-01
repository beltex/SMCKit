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
    
    let smc = SMC()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
        smc.open()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of
        // each test method in the class.
        smc.close()
        
        super.tearDown()
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
}
