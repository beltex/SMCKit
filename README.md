SMCKit
======

An Apple System Management Controller (SMC) library & command line tool in Swift
for Intel based Macs. The library works by talking to the AppleSMC.kext (kernel
extension), the private driver for the SMC. Read temperature sensors, get and
set fan speed (RPM), and more.

- For an example usage of this library, see
  [dshb](https://github.com/beltex/dshb), a macOS system monitor in Swift
- For other system related statistics in Swift for macOS, see
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

- [Xcode 9.0 (Swift 4.0)](https://developer.apple.com/xcode/downloads/)
- macOS 10.12 Sierra and above **for development** (due to Xcode)
- OS X 10.9 Mavericks and above **for use** (due to Swift)


### Clone

Make sure to use the recursive option on clone to initialize all submodules.

```sh
git clone --recursive https://github.com/beltex/SMCKit
```

Incase you have already cloned the repository, run the following inside the
project directory.

```sh
git submodule update --init
```


### SMCKitTool

A macOS command line tool for interfacing with the SMC using SMCKit. The
[CommandLine](https://github.com/jatoben/CommandLine) library is used for
the CLI and [ronn](https://github.com/rtomayko/ronn) for generating the
[manual page](https://beltex.github.io/SMCKit).

##### Install

This will build SMCKitTool (`smckit(1)`) from source and place the binary and
manual page in your path.

```
make install
```

##### Example

```sh
$ smckit
-- Temperature --
AMBIENT_AIR_0           34.0°C
CPU_0_DIE               48.0°C
CPU_0_PROXIMITY         39.0°C
ENCLOSURE_BASE_0        29.0°C
ENCLOSURE_BASE_1        29.0°C
ENCLOSURE_BASE_2        28.0°C
HEATSINK_1              34.0°C
MEM_SLOTS_PROXIMITY     36.0°C
PALM_REST               27.0°C
-- Fan --
[id 0] Right Side
    Min:      1299 RPM
    Max:      6199 RPM
    Current:  1292 RPM
-- Power --
AC Present:       true
Battery Powered:  false
Charging:         false
Battery Ok:       true
Battery Count:    1
-- Misc --
Disc in ODD:      false
```


### Library Usage Notes

- The use of this library  will almost certainly not be allowed in the
  Mac App Store as it is essentially using a private API
- If you are creating a macOS command line tool, you cannot use SMCKit as a
  library as Swift does not currently support static libraries. In such a
  case, the `SMC.swift` file must simply be included in your project as another
  source file. See
  [SwiftInFlux/Runtime Dynamic Libraries](https://github.com/ksm/SwiftInFlux#runtime-dynamic-libraries)
  for more information and both SMCKitTool &
  [dshb](https://github.com/beltex/dshb) as examples of such a case.


### References

There are many projects that interface with the SMC for one purpose or another.
Credit is most certainly due to them for the reference. Such projects as:

- iStat Pro
- [osx-cpu-temp](https://github.com/lavoiesl/osx-cpu-temp)
- [PowerManagement](http://www.opensource.apple.com/source/PowerManagement/)
- [powermetrics(1)](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/powermetrics.1.html)
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
