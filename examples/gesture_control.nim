## Gesture Control Demo
##
## Demonstrates the APDS9960 gesture/proximity/color sensor
## Maps gestures to audio effects
##
## Hardware:
##   - Daisy Seed
##   - APDS9960 sensor on I2C
##   - I2C connections: SCL=D11 (PB8), SDA=D12 (PB9)
##
## Features:
##   - Swipe UP: Increase filter cutoff
##   - Swipe DOWN: Decrease filter cutoff
##   - Swipe LEFT: Decrease effect mix
##   - Swipe RIGHT: Increase effect mix
##   - Proximity: Controls modulation depth
##   - LED indicates gesture detection

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/libdaisy_serial
import ../src/dev/apds9960
import std/math
useDaisyNamespace()


var
  sensor: Apds9960I2C
  cutoff = 1000.0'f32      # Filter cutoff frequency (100Hz - 10kHz)
  mix = 0.5'f32            # Dry/wet mix (0.0 - 1.0)
  modDepth = 0.0'f32       # Modulation depth from proximity
  
# Simple one-pole lowpass filter state
var
  filterStateL = 0.0'f32
  filterStateR = 0.0'f32

proc clamp(value, min, max: float32): float32 {.inline.} =
  if value < min: return min
  if value > max: return max
  return value

proc onePoleFilter(input, cutoff: float32, state: var float32): float32 {.inline.} =
  ## Simple one-pole lowpass filter
  const sampleRate = 48000.0'f32
  let rc = 1.0'f32 / (2.0'f32 * PI * cutoff)
  let dt = 1.0'f32 / sampleRate
  let alpha = dt / (rc + dt)
  state = state + alpha * (input - state)
  return state

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  for i in 0..<size:
    let inL = input[0][i]
    let inR = input[1][i]
    
    # Apply lowpass filter with proximity-based modulation
    let modulatedCutoff = cutoff * (1.0'f32 + modDepth * 0.5'f32)
    let filteredL = onePoleFilter(inL, modulatedCutoff, filterStateL)
    let filteredR = onePoleFilter(inR, modulatedCutoff, filterStateR)
    
    # Mix dry and wet signals
    output[0][i] = inL * (1.0'f32 - mix) + filteredL * mix
    output[1][i] = inR * (1.0'f32 - mix) + filteredR * mix

proc main() =
  var daisy = initDaisy()
  
  # Initialize APDS9960 sensor
  var sensorConfig: Apds9960Config
  sensorConfig.transport_config.periph = I2C_1
  sensorConfig.transport_config.speed = I2C_400KHZ
  sensorConfig.transport_config.scl = D11()
  sensorConfig.transport_config.sda = D12()
  
  # Enable gesture, proximity, and color sensing
  sensorConfig.gesture_mode = true
  sensorConfig.prox_mode = true
  sensorConfig.color_mode = true
  
  startLog()
  printLine("APDS9960 Gesture Control Demo")
  printLine()
  
  # Initialize sensor
  let initResult = sensor.init(sensorConfig)
  if initResult != APDS9960_OK:
    printLine("ERROR: Sensor initialization failed!")
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  
  printLine("Sensor initialized")
  printLine()
  printLine("Gesture controls:")
  printLine("  UP    -> Increase cutoff")
  printLine("  DOWN  -> Decrease cutoff")
  printLine("  RIGHT -> Increase mix")
  printLine("  LEFT  -> Decrease mix")
  printLine("  Proximity -> Modulation")
  printLine()
  
  # Start audio processing
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  daisy.startAudio(audioCallback)
  
  var ledState = false
  var loopCount = 0'u32
  
  while true:
    # Read gesture
    let gesture = sensor.readGesture()
    
    var gestureDetected = false
    case gesture
    of APDS9960_UP:
      cutoff = clamp(cutoff + 500.0'f32, 100.0'f32, 10000.0'f32)
      printLine("Gesture: UP -> Cutoff increased")
      gestureDetected = true
      
    of APDS9960_DOWN:
      cutoff = clamp(cutoff - 500.0'f32, 100.0'f32, 10000.0'f32)
      printLine("Gesture: DOWN -> Cutoff decreased")
      gestureDetected = true
      
    of APDS9960_LEFT:
      mix = clamp(mix - 0.1'f32, 0.0'f32, 1.0'f32)
      printLine("Gesture: LEFT -> Mix decreased")
      gestureDetected = true
      
    of APDS9960_RIGHT:
      mix = clamp(mix + 0.1'f32, 0.0'f32, 1.0'f32)
      printLine("Gesture: RIGHT -> Mix increased")
      gestureDetected = true
      
    else:
      discard
    
    # Read proximity (0-255, where higher = closer)
    let proximity = sensor.readProximity()
    
    # Map proximity to modulation depth (0.0 - 1.0)
    modDepth = proximity.float32 / 255.0'f32
    
    # Blink LED on gesture detection
    if gestureDetected:
      ledState = true
      daisy.setLed(ledState)
      daisy.delay(100)
      ledState = false
    
    daisy.setLed(ledState)
    
    # Print status every 50 loops (~0.5 seconds at 10ms delay)
    inc loopCount
    if loopCount mod 50 == 0:
      print("Cutoff: ")
      print(cutoff.int)
      print("Hz | Mix: ")
      print((mix * 100.0'f32).int)
      print("% | Proximity: ")
      print(proximity.int)
      
      # Optionally read color data
      if loopCount mod 200 == 0:  # Every 2 seconds
        var r, g, b, c: uint16
        sensor.getColorData(r.addr, g.addr, b.addr, c.addr)
        print(" | RGB: ")
        print(r.int)
        print(",")
        print(g.int)
        print(",")
        print(b.int)
      
      printLine()
    
    daisy.delay(10)  # Update at ~100Hz

when isMainModule:
  main()
