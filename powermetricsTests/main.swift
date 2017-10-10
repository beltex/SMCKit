//
// Test SMCKit by cross-referencing with Apple's powermetrics(1) tool. This is
// not a pretty test by any means, were running a command line tool and parsing
// it's output. However, at this point in time, powermetrics is the only
// publicly available tool that displays SMC data from Apple, so it's our only
// "official" reference. Requires root privileges due to powermetrics.
//
// References:
//
// http://practicalswift.com/2014/06/25/how-to-execute-shell-commands-from-swift/
//
// powermetricsTests/main.swift
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

import Foundation


// powermetrics added the SMC sampler in 10.10
let processInfo = ProcessInfo()
let Yosemite    = OperatingSystemVersion(majorVersion: 10,
                                           minorVersion: 0,
                                           patchVersion: 0)

if !processInfo.isOperatingSystemAtLeast(Yosemite) {
    print("ERROR: powermetrics requires OS X 10.10 (Yosemite) or greater")
    exit(EX_USAGE)
}


// Setup SMC
do {
    try SMCKit.open()
} catch {
    print(error)
    exit(EX_UNAVAILABLE)
}


// Setup command to run powermetrics
let powermetrics = Process()
powermetrics.launchPath = "/usr/bin/powermetrics"

/*
TODO: Taking only 1 sample right now. In the future, could change this to take
      many, and average it out to compare with SMCKit. However, would need to in
      parallel run the SMCKit samples (need a serial GCD queue that fires at 1
      second intervals)
*/
powermetrics.arguments  = ["-s", "smc", "-n", "1"]

let pipe = Pipe()
powermetrics.standardOutput = pipe
powermetrics.launch()
let data = pipe.fileHandleForReading.readDataToEndOfFile()


// Get SMC data right after powermetrics has run. This is because it first
// prints out some general information about the machine, and then seems to
// sleep for 1 second to "line up" its sampling window
let smcFanCount          = try! SMCKit.fanCount()
let smcRPM               = try! SMCKit.fanCurrentSpeed(0)

// The key used by powermetrics was determined via DTrace script below
// https://gist.github.com/beltex/acbbeef815a7be938abf
let smcCPUDieTemperature =
    try! SMCKit.temperature(TemperatureSensors.CPU_0_DIE.code)


// Parse the output from powermetrics
// TODO: Unknown format of various cases - multiple fans, no fans, 2 CPUs
//       (Mac Pro)
if let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
    // Break it down into lines
    let lines = output.components(separatedBy: "\n")

    for line in lines {
        let tokens = line.components(separatedBy: " ")

        if line.hasPrefix("Fan:") && line.hasSuffix("rpm") {
            let powermetricsRPM = Int(tokens[1])!
            let diff = abs(Int(smcRPM) - powermetricsRPM)

            print("SMCKit fan 0 RPM:     \(smcRPM)")
            print("powermetrics fan RPM: \(powermetricsRPM)")
            assert(diff >= 0 && diff <= 5, "RPM differs by more than +/- 5")

        } else if line.hasPrefix("CPU die temperature:") &&
                  line.hasSuffix("C") {
            let powermetricsCPUDieTemperature =
                (tokens[3] as NSString).doubleValue
            let diff = abs(smcCPUDieTemperature - powermetricsCPUDieTemperature)

            print("SMCKit CPU_0_DIE:                 \(smcCPUDieTemperature)")
            print("powermetrics CPU die temperature: " +
                  "\(powermetricsCPUDieTemperature)")
            assert(diff >= 0 && diff <= 1,
                   "Temperature differs by more than +/- 1")
        }
    }
}

SMCKit.close()
