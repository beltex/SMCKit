//
// SMCKitTests.swift
// SMCKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://beltex.github.io>
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

import XCTest
import SMCKit
import DiscRecording

/**
Notes

- Don't have a master list of what each Mac has (which fans, sensors, etc.) to
  check against
- Hard to validate return values, we can test that the calls don't fail, but not
  if the return values are correct necessarily. In some cases, can cross-check
  them via other APIs and tools (battery, powermetrics, etc.)
- See also powermetricsTests which cross-checks fan and CPU temperature


TODO

- Model specific tests?
- Could use the Intel Power Gadget API as a cross-check for CPU temperature.
  Problem is, requires installing a driver (kext) + framework. The need for a
  kext seems to be due to the rdmsr instruction, which can only be executed in
  kernel-space (temperature seems to be stored in a Model Specific Register -
  MSR). Could bundle it with SMCKit possibly to make that easier. Also, only
  works on second generation Intel Core 2 Duo chips and on.
*/
class SMCKitTests: XCTestCase {

    /// List of internal ODD devices
    var internalODD = [DRDevice]()
    
    // TODO: Setup once?
    override func setUp() {
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
        super.setUp()

        do {
            try SMCKit.open()
        } catch {
            print(error)
            fatalError()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of
        // each test method in the class.
        SMCKit.close()

        super.tearDown()
    }
    
//    func testOpenConnectionTwice() {
//        XCTAssertNotEqual(smc.open(), kIOReturnSuccess)
//    }
//
//    func testCloseConnectionTwice() {
//        XCTAssertEqual(smc.close(), kIOReturnSuccess)
//        XCTAssertNotEqual(smc.close(), kIOReturnSuccess)
//
//        // Test that we can reopen and things still work
//        smc.open()
//        XCTAssertGreaterThanOrEqual(smc.getNumFans().numFans, UInt(1))
//        XCTAssertEqual(smc.close(), kIOReturnSuccess)
//    }
    
    func testTemperatureValues() {
        let temperatureSensors = try! SMCKit.allKnownTemperatureSensors()
        
        for sensor in temperatureSensors {
            let temperature = try! SMCKit.temperature(sensor.code)
            
            XCTAssertGreaterThan(temperature, -128.0)
            XCTAssertLessThan(temperature, 128.0)
        }
    }

    func testFanCount() {
        // All Macs until now have at least 1 fan, except for the new 2015
        // MacBook (8,1)
        let fanCount = try! SMCKit.fanCount()

        if modelName() == "MacBook8,1" {
            // Fanless
            XCTAssertEqual(fanCount, 0)
            return
        }

        XCTAssertGreaterThanOrEqual(fanCount, 1)

        // Don't know the max number of fans, probably no more than 2 or 3,
        // but we'll give it some slack incase
        XCTAssertLessThanOrEqual(fanCount, 4)
    }
    
    func testisKeyFound() {
        XCTAssertFalse(try! SMCKit.isKeyFound(FourCharCode(fromString: "CERN")))
        XCTAssertFalse(try! SMCKit.isKeyFound(FourCharCode(fromString: "NASA")))

        // We should be able to rely on always having this key. Returns the
        // number of valid keys on this machine
        XCTAssertTrue(try! SMCKit.isKeyFound(FourCharCode(fromString: "#KEY")))
    }

    func testODD() {
        // Cross check via DiscRecording framework
        //
        // Handy Refs:
        // http://stackoverflow.com/questions/8770048/objective-c-drdevice-h
        // https://developer.apple.com/legacy/library/samplecode/DeviceListener/
        // http://stackoverflow.com/a/24049111

        let ODDStatusSMC: Bool

        do {
            ODDStatusSMC = try SMCKit.isOpticalDiskDriveFull()
        } catch SMCKit.SMCError.keyNotFound {
            ODDStatusSMC = false
        } catch {
            print(error)
            fatalError()
        }


        if DRDevice.devices().count == 0 {
            // TODO: This means that there are no ODD that have burn capability?
            //       Should be fine, as all Apple drives should have it
            print("No ODD devices")
            XCTAssertTrue(ODDStatusSMC == false)
            return
        }

        
        // To get the ODD object, need to reg for notification and wait. Since,
        // were looking for an internel device, should be instant.
        // See deviceAppeared() helper.
        DRNotificationCenter.currentRunLoop().addObserver(
            self,
            selector: #selector(SMCKitTests.deviceAppeared(_:)),
            name: NSNotification.Name.DRDeviceAppeared.rawValue,
            object: nil
        )
        
        // TODO: sleep here just incase for notification to be sent?

        
        // TODO: Ignoring the Mac Pro case for now, with 2 drives
        if internalODD.count == 1 {
            let ODDStatus =
                internalODD[0].status()[DRDeviceMediaStateKey] as! String
            
            switch ODDStatus {
            case DRDeviceMediaStateMediaPresent:
                XCTAssertTrue(ODDStatusSMC)
            case DRDeviceMediaStateInTransition:
                // TODO: Should sleep and wait for state to become "stable",
                //       DRDeviceStatusChangedNotification
                // TODO: Throw a fail here?
                break
            case DRDeviceMediaStateNone:
                XCTAssertFalse(ODDStatusSMC)
            default:
                break
            }
        }
        
        DRNotificationCenter.currentRunLoop().removeObserver(
            self,
            name: NSNotification.Name.DRDeviceAppeared.rawValue,
            object: nil
        )
    }
    
    func testBatteryPowerMethods() {
        var isLaptop    = false
        var ASPCharging = false
        var ASPCharged  = false
        
        // Check if machine is a laptop - if it is, we use the service to cross
        // check our values
        // TODO: Simplify I/O Kit calls here - can do it in a single call
        // TODO: What if its a MacBook with a removable battery and its out?
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                      IOServiceNameMatching("AppleSmartBattery"))
        if service != 0 {
            isLaptop = true
            
            // Getting these values to cross ref
            var prop = IORegistryEntryCreateCFProperty(
                service, "IsCharging" as CFString!,
                kCFAllocatorDefault,
                0
            )
            
            ASPCharging = prop?.takeUnretainedValue() as! Bool
            
            prop = IORegistryEntryCreateCFProperty(
                service, "FullyCharged" as CFString!,
                kCFAllocatorDefault,
                0
            )
            
            ASPCharged = prop?.takeUnretainedValue() as! Bool
        }
        
        let info = try! SMCKit.batteryInformation()


        let batteryPowered = info.isBatteryPowered
        let batteryOk      = info.isBatteryOk
        let ACPresent      = info.isACPresent
        let charging       = info.isCharging
        let numBatteries   = info.batteryCount

        if isLaptop {
            // TODO: Is there any Mac that supports more then 1?
            XCTAssertEqual(numBatteries, 1)
            
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
            XCTAssertEqual(numBatteries, 0)
        }
        
        
        // TODO: Make sure this is called, even if tests above fail
        IOObjectRelease(service)
    }

    func testFourCharCodeExtension() {
        let data: [(FourCharCode, String)] = [(1177567587, "F0Ac"),
                                              (1413689414, "TC0F")]

        for (encoded, decoded) in data {
            XCTAssertEqual(encoded, FourCharCode(fromString: decoded))
            XCTAssertEqual(decoded, encoded.toString())
        }
    }

    func testIntExtension() {
        let data: [(FPE2, Int)] = [((31, 64),  2000), ((56, 244), 3645),
                                   ((96, 220), 6199)]

        for (encoded, decoded) in data {
            let toFPE2 = decoded.toFPE2()
            XCTAssert(encoded.0 == toFPE2.0 && encoded.1 == toFPE2.1)

            XCTAssertEqual(decoded, Int(fromFPE2: encoded))
        }
    }


    //--------------------------------------------------------------------------
    // MARK: Helpers
    //--------------------------------------------------------------------------

    /// Callback on disc recording device (ODD) being found.
    ///
    /// NOTE: Must not be private ACL, otherwise selector can't be reached
    func deviceAppeared(_ aNotification: Notification) {
        let newDevice  = aNotification.object as! DRDevice
        let deviceInfo = newDevice.info()
        
        let supportLevel = deviceInfo?[DRDeviceSupportLevelKey] as! String
        let interconnect =
            deviceInfo?[DRDevicePhysicalInterconnectLocationKey] as! String
        
        if interconnect == DRDevicePhysicalInterconnectLocationInternal &&
           supportLevel == DRDeviceSupportLevelAppleShipping {
            // The supposition here is that the SMC will only know about
            // internal Apple "made" ODD, and not a 3rd party one that someone
            // swapped in
            internalODD.append(newDevice)
        }
    }


    /// Get the model name of this machine. Same as "sysctl hw.model". Via
    /// SystemKit
    func modelName() -> String {
        var name = String()
        var mib = [CTL_HW, HW_MODEL]

        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = MemoryLayout<io_name_t>.size

        let ptr    = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)

        if result == 0 {
            let cString =
                UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
            name = String(cString: cString)
        }

        ptr.deallocate(capacity: 1)

        return name
    }
}
