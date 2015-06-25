SMCKit
======

An OS X System Management Controller (SMC) library & command line tool in Swift
for Intel based Macs. The library works by talking to the AppleSMC.kext (kernel
extension), the private driver for the SMC. Read temperature sensors, get and
set fan speed (RPM), and more.

- For a C based version, see [libsmc](https://github.com/beltex/libsmc)
- For an example usage of this library, see
  [dshb](https://github.com/beltex/dshb), an OS X system monitor in Swift
- For other system related statistics in Swift for OS X, see
  [SystemKit](https://github.com/beltex/SystemKit)


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

- [System Management Controller](https://en.wikipedia.org/wiki/System_Management_Controller)
- [System Management Unit](https://en.wikipedia.org/wiki/System_Management_Unit)
- [Power Management Unit](https://en.wikipedia.org/wiki/Power_Management_Unit)


### Requirements

- [Xcode 7 Beta 2](https://developer.apple.com/xcode/downloads/)
- OS X 10.9+
    - This is due to Swift


### SMCKitTool

An OS X command line tool for interfacing with the SMC using SMCKit. The
[CommandLine](https://github.com/jatoben/CommandLine) library is used for
the CLI and [ronn](https://github.com/rtomayko/ronn) for generating the
[manual page](http://beltex.github.io/SMCKit/smckit.1.html).

##### Install

This will build SMCKitTool (`smckit(1)`) from source and place the binary and
manual page in your path.

```
make install
```

##### Example

```sh
$ smckit
-- TEMPERATURE --
CPU_0_DIODE
  70.0°C
CPU_0_PROXIMITY
  58.0°C
ENCLOSURE_BASE_0
  35.0°C
ENCLOSURE_BASE_1
  35.0°C
ENCLOSURE_BASE_2
  34.0°C
ENCLOSURE_BASE_3
  38.0°C
HEATSINK_1
  58.0°C
NORTHBRIDGE_DIODE
  65.0°C
NORTHBRIDGE_PROXIMITY
  53.0°C
PALM_REST
  34.0°C
-- FAN --
[id 0] Exhaust
  Current:  1324 RPM
  Min:      1299 RPM
  Max:      6199 RPM
-- POWER --
AC Present:       true
Battery Powered:  false
Charging:         false
Battery Ok:       true
Max Batteries:    1
-- MISC --
Disc in ODD:      false
```


### Library Usage Notes

- The use of this library  will almost certainly not be allowed in the
  Mac App Store as it is essentially using a private API
- If you are creating an OS X command line tool, you cannot use SMCKit as a
  library as Swift does not currently support static libraries. In such a
  case, the `SMC.swift` file must simply be included in your project as another
  source file. See
  [SwiftInFlux/Runtime Dynamic Libraries](https://github.com/ksm/SwiftInFlux#runtime-dynamic-libraries)
  for more information and both SMCKitTool &
  [dshb](https://github.com/beltex/dshb) as examples of such a case.


### References

There are many projects that interface with the SMC for one purpose or another.
Credit is most certainly due to them for the reference code. Such projects as:

- iStat Pro
- [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp)
- [PowerManagement](http://www.opensource.apple.com/source/PowerManagement/)
- [smcFanControl](https://github.com/hholtmann/smcFanControl)

Handy I/O Kit references:

- [iOS Hacker's Handbook](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118204123.html)
- [Mac OS X and iOS Internals: To the Apple's Core](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118057651.html)
- [OS X and iOS Kernel Programming](http://www.apress.com/apple-mac/objective-c/9781430235361)


### License

This project is under the **MIT License**.


### Fun

While the SMC driver is closed source, the call strucutre and definition of
certain structs needed to interact with it (see `SMCParamStruct`) happened to
appear in the open source Apple **PowerManagement** project at around version
211, and soon after disappeared. They can be seen in the
[PrivateLib.c](http://www.opensource.apple.com/source/PowerManagement/PowerManagement-211/pmconfigd/PrivateLib.c)
file under `pmconfigd`. In the very same source file, the following snippet can be
found:

```c
// And simply AppleSMC with kCFBooleanTrue to let them know time is changed.
// We don't pass any information down.
IORegistryEntrySetCFProperty( _smc,
                    CFSTR("TheTimesAreAChangin"),
                    kCFBooleanTrue);
```

Almost certainly a reference to Bob Dylan's
<a href="https://en.wikipedia.org/wiki/The_Times_They_Are_a-Changin%27_(song)">The Times They Are a-Changin'</a> :)
