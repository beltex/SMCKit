swift-smc
=========

A System Management Controller (SMC) API in Swift from user space for Intel
based Macs. The API works by talking to the AppleSMC.kext (kernel
extension), the closed source driver for the SMC.

Requires Xcode 6 - Beta 5.

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





### Fun

In the very same PrivateLib.c file, the following snippet can be found:

```c
// And simply AppleSMC with kCFBooleanTrue to let them know time is changed.
// We don't pass any information down.
IORegistryEntrySetCFProperty( _smc,
                    CFSTR("TheTimesAreAChangin"),
                    kCFBooleanTrue);
```

Almost certainly a reference to Bob Dylan's
<a href="http://en.wikipedia.org/wiki/The_Times_They_Are_a-Changin%27_(song)">The Times They Are a-Changin'</a>
:)


### References

- [OS X and iOS Kernel Programming](http://www.apress.com/9781430235361-4892)
- [Mac OS X and iOS Internals: To the Apple's Core](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118057651.html)
- [iOS Hacker's Handbook](http://ca.wiley.com/WileyCDA/WileyTitle/productCd-1118204123.html)
