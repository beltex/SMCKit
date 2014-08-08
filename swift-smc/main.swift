import IOKit

var smc = SMC()

if (smc.openSMC() != kIOReturnSuccess) {
        println("ERROR")
}

println(smc.getTemp(SMC.TMP.CPU_0_DIODE))
println(smc.getFanRPM(SMC.FAN.FAN_0))

smc.closeSMC()