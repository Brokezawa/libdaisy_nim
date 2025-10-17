## Simple ADC Example - Clean API
import panicoverride
## 
## Reading a single analog input

import ../src/libdaisy
import ../src/libdaisy_controls
import ../src/libdaisy_serial
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  
  # Initialize ADC on pin A0
  var adc = initAdc(daisy, [A0()])
  adc.start()
  
  startLog()
  printLine("Simple ADC Example - Pin A0")
  printLine()
  
  while true:
    let value = adc.value(0)          # 0.0 to 1.0
    let voltage = value * 3.3         # Convert to voltage
    
    # Print value with bar graph
    print("Value: ")
    print(value)
    print(" | Voltage: ")
    print(voltage)
    print("V | ")
    
    # Simple bar graph
    let bars = int(value * 20)
    for i in 0..<bars:
      print("#")
    printLine()
    
    daisy.delay(100)

when isMainModule:
  main()
