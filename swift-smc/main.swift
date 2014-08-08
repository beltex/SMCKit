import IOKit

var smc = SMC()

if (smc.openSMC() != kIOReturnSuccess) {
        println("ERROR")
}

println(smc.getTemp(SMC.TMP.CPU))

smc.closeSMC()