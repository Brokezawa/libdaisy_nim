## ADC Configuration Example
## 
## Demonstrates different ADC configuration options including
## conversion speeds and oversampling rates.
## 
## This example shows how to optimize ADC settings for different use cases:
## - Fast conversions with less accuracy
## - Slow conversions with high accuracy
## - Different oversampling rates

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_adc
import ../src/libdaisy_serial

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Configure 2 channels with different conversion speeds
  var channels: array[2, AdcChannelConfig]
  
  # Channel 0: Fast conversion (for rapidly changing signals)
  channels[0].initSingle(A0(), SPEED_1CYCLES_5)
  
  # Channel 1: Slow conversion (for more accurate readings)
  channels[1].initSingle(A1(), SPEED_810CYCLES_5)
  
  # Initialize ADC with different oversampling options
  # Try: OVS_NONE, OVS_4, OVS_32, OVS_256, OVS_1024
  var adc = initAdcHandle(channels, OVS_64)
  adc.start()
  
  startLog()
  printLine("ADC Configuration Example")
  printLine("Ch0: Fast conversion (1.5 cycles)")
  printLine("Ch1: Slow conversion (810.5 cycles)")
  printLine("Oversampling: 64x")
  printLine()
  
  var sampleCount = 0
  var sum0: float = 0.0
  var sum1: float = 0.0
  
  while true:
    # Read both channels
    let fast = adc.getFloat(0)
    let slow = adc.getFloat(1)
    
    # Accumulate for averaging
    sum0 += fast
    sum1 += slow
    inc sampleCount
    
    # Every 10 samples, display stats
    if sampleCount >= 10:
      let avg0 = sum0 / 10.0
      let avg1 = sum1 / 10.0
      
      print("Fast (A0): ")
      print(fast)
      print(" avg=")
      print(avg0)
      print(" | Slow (A1): ")
      print(slow)
      print(" avg=")
      print(avg1)
      printLine()
      
      # Also show raw values
      let raw0 = adc.get(0)
      let raw1 = adc.get(1)
      print("Raw: ")
      print(raw0.int)
      print(" | ")
      print(raw1.int)
      printLine()
      printLine()
      
      # Reset accumulators
      sampleCount = 0
      sum0 = 0.0
      sum1 = 0.0
    
    hw.delay(50)

when isMainModule:
  main()
