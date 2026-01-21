## ADC Multi-Channel Example
## 
## Demonstrates reading multiple analog inputs using the standalone ADC wrapper.
## This example reads 4 analog inputs and displays their values.

import panicoverride
import ../src/libdaisy
import ../src/per/adc
import ../src/per/uart

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Configure 4 ADC channels
  var channels: array[4, AdcChannelConfig]
  channels[0].initSingle(A0())
  channels[1].initSingle(A1())
  channels[2].initSingle(A2())
  channels[3].initSingle(A3())
  
  # Initialize ADC with 32x oversampling
  var adc = initAdcHandle(channels, OVS_32)
  adc.start()
  
  startLog()
  printLine("ADC Multi-Channel Example")
  printLine("Reading 4 analog inputs (A0-A3)")
  printLine()
  
  while true:
    # Read all channels
    let ch0 = adc.getFloat(0)
    let ch1 = adc.getFloat(1)
    let ch2 = adc.getFloat(2)
    let ch3 = adc.getFloat(3)
    
    # Display values
    print("A0: ")
    print(ch0)
    print(" | A1: ")
    print(ch1)
    print(" | A2: ")
    print(ch2)
    print(" | A3: ")
    print(ch3)
    printLine()
    
    # Blink LED at different rate based on first input
    if ch0 > 0.5:
      hw.setLed(true)
    else:
      hw.setLed(false)
    
    hw.delay(100)

when isMainModule:
  main()
