## ADC Multiplexed Input Example
## 
## Demonstrates reading multiple analog inputs through a CD4051 8-channel multiplexer.
## This allows reading 8 analog inputs using only 1 ADC pin + 3 control pins.
## 
## Hardware setup:
## - CD4051 analog multiplexer
## - Mux output (Y) connected to A0
## - Select pins: S0 -> D0, S1 -> D1, S2 -> D2
## - INH (inhibit) connected to GND
## - VDD connected to 3.3V
## - VEE connected to GND
## - VSS connected to GND
## - Up to 8 analog inputs connected to Y0-Y7

import panicoverride
import ../src/libdaisy
import ../src/per/adc
import ../src/per/uart

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Configure 1 ADC channel with 8-way multiplexer
  var channels: array[1, AdcChannelConfig]
  channels[0].initMux(
    adcPin = A0(),      # Mux output
    muxChannels = 8,    # 8 inputs (CD4051)
    mux0 = D0(),        # S0 select line
    mux1 = D1(),        # S1 select line
    mux2 = D2()         # S2 select line
  )
  
  # Initialize ADC
  var adc = initAdcHandle(channels, OVS_32)
  adc.start()
  
  startLog()
  printLine("ADC Multiplexed Input Example")
  printLine("Reading 8 analog inputs via CD4051 mux")
  printLine()
  
  var counter = 0
  var ledState = false
  
  while true:
    # Read all 8 multiplexed inputs
    print("Mux inputs: ")
    for i in 0..<8:
      let value = adc.getMuxFloat(0, i)
      print(value)
      if i < 7:
        print(" | ")
    printLine()
    
    # Display bar graph for first input
    let input0 = adc.getMuxFloat(0, 0)
    let bars = int(input0 * 20)
    print("[")
    for i in 0..<20:
      if i < bars:
        print("#")
      else:
        print(" ")
    print("] ")
    print(input0)
    printLine()
    printLine()
    
    # Blink LED at rate controlled by first mux input
    inc counter
    let blinkSpeed = int(input0 * 10) + 1
    if (counter mod blinkSpeed) == 0:
      ledState = not ledState
      hw.setLed(ledState)
    
    hw.delay(50)

when isMainModule:
  main()
