SMCKit
======

A System Management Controller (SMC) library in pure Swift from user space for
Intel based Macs. The library works by talking to the AppleSMC.kext (kernel
extension), the closed source driver for the SMC. Read temperature sensors,
get and set fan speed (RPM), etc.

For a C based version see [libsmc](https://github.com/beltex/libsmc).


### System Management Controller

_"The System Management Controller (SMC) is an internal subsystem introduced by
Apple Inc. with the introduction of their new Intel processor based machines
in 2006. It takes over the functions of the SMU. The SMC manages thermal and
power conditions to optimize the power and airflow while keeping audible noise
to a minimum. Power consumption and temperature are monitored by the operating
system, which communicates the necessary adjustments back to the SMC. The SMC
makes the changes, slowing down or speeding up fans as necessary."_
-via Wikipedia

For more see:

- [System Management Controller](http://en.wikipedia.org/wiki/System_Management_Controller)
- [System Management Unit](http://en.wikipedia.org/wiki/System_Management_Unit)
- [Power Management Unit](http://en.wikipedia.org/wiki/Power_Management_Unit)


### Requirements

- [Xcode 6.1](https://developer.apple.com/xcode/downloads/)
- OS X 10.9+


### Installation

The quick and easy solution is to simply copy the `SMC.swift` file into your
project. For a more proper longer term solution, see below via
[Alamofire](https://github.com/Alamofire/Alamofire).

_Due to the current lack of [proper infrastructure](http://cocoapods.org) for
Swift dependency management, using SMCKit in your project requires the following
steps:_

1. Add SMCKit as a [submodule](http://git-scm.com/docs/git-submodule) by opening
   the Terminal, `cd`-ing into your top-level project directory, and entering
   the command `git submodule add https://github.com/beltex/SMCKit.git`
2. Open the `SMCKit` folder, and drag `SMCKit.xcodeproj` into the file navigator
   of your project.
3. In Xcode, navigate to the target configuration window by clicking on the blue
   project icon, and selecting the application target under the "Targets"
   heading in the sidebar.
4. Ensure that the deployment target of SMCKit.framework matches that of the
   application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Target Dependencies" group, and add `SMCKit.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy
   Files Phase". Rename this new phase to "Copy Frameworks", set the
   "Destination" to "Frameworks", and add `SMCKit.framework`.

**NOTE**: If you are building an OS X command line tool, the above won't work.
          See here for
          [why](https://github.com/ksm/SwiftInFlux#runtime-dynamic-libraries).
          Instead of the last two steps, do the following:

> Expand the "Compile Sources" group, and add `SMC.swift`.


### Usage

```swift
// If your using SMCKit as a framework in your project, you will only need the
// second import statement
import IOKit
import SMCKit

let smc = SMC()

if (smc.open() == kIOReturnSuccess) {
    println("CPU 0 Diode Temperature: \(smc.getTMP(SMC.TMP.CPU_0_DIODE).tmp)°C")
    println("Fan 0 Speed: \(smc.getFanRPM(0).rpm) RPM")
    smc.close()
}
```

Also, keep in mind that Swift currently offers no ABI stability. See
[here](https://github.com/ksm/SwiftInFlux#abi-stability).


### References

There are many projects that interface with the SMC for one purpose or another. Credit is most
certainly due to them for the reference code. Such projects as:

- [iStat Pro](https://www.apple.com/downloads/dashboard/status/istatpro.html)
- [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp)
- [smcFanControl](https://github.com/hholtmann/smcFanControl)

Handy I/O Kit references:

- [iOS Hacker's Handbook](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118204123.html)
- [Mac OS X and iOS Internals: To the Apple's Core](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118057651.html)
- [OS X and iOS Kernel Programming](http://www.apress.com/9781430235361-4892)


### License

This project is under the **GNU General Public License v2.0**.


### Fun

In the very same
[PrivateLib.c](http://www.opensource.apple.com/source/PowerManagement/PowerManagement-211/pmconfigd/PrivateLib.c)
file, the following snippet can be found:

```c
// And simply AppleSMC with kCFBooleanTrue to let them know time is changed.
// We don't pass any information down.
IORegistryEntrySetCFProperty( _smc,
                    CFSTR("TheTimesAreAChangin"),
                    kCFBooleanTrue);
```

Almost certainly a reference to Bob Dylan's
<a href="http://en.wikipedia.org/wiki/The_Times_They_Are_a-Changin%27_(song)">The Times They Are a-Changin'</a>
. [Enjoy](http://hypem.com/track/5zf9/Bob+Dylan+-+The+Times+They+Are+A-Changin') :)
