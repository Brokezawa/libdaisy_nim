## IMU Motion Control Demo
##
## Demonstrates the ICM20948 9-axis IMU sensor
## Maps motion to audio filter parameters
##
## Hardware:
##   - Daisy Seed
##   - ICM20948 sensor on I2C
##   - I2C connections: SCL=D11 (PB8), SDA=D12 (PB9)
##
## Features:
##   - Accelerometer tilt controls filter cutoff
##   - Gyroscope rotation controls resonance
##   - Magnetometer heading controls mix amount
##   - LED blinks on motion detection

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/libdaisy_serial
import ../src/dev/icm20948
import std/math
useDaisyNamespace()


var
  imu: Icm20948I2C
  cutoff = 1000.0'f32      # Filter cutoff frequency
  resonance = 0.5'f32      # Filter resonance
  mix = 0.5'f32            # Dry/wet mix
  lastAccelMag = 0.0'f32   # For motion detection

# Simple one-pole lowpass filter state
var
  filterStateL = 0.0'f32
  filterStateR = 0.0'f32

proc mapRange(value, inMin, inMax, outMin, outMax: float32): float32 {.inline.} =
  ## Map value from input range to output range
  result = outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
  if result < outMin: result = outMin
  if result > outMax: result = outMax

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
    
    # Apply resonant lowpass filter
    let filteredL = onePoleFilter(inL, cutoff, filterStateL)
    let filteredR = onePoleFilter(inR, cutoff, filterStateR)
    
    # Mix dry and wet signals
    output[0][i] = inL * (1.0'f32 - mix) + filteredL * mix
    output[1][i] = inR * (1.0'f32 - mix) + filteredR * mix

proc main() =
  var daisy = initDaisy()
  
  # Initialize IMU with I2C transport
  var imuConfig: Icm20948I2CConfig
  imuConfig.transport_config.periph = I2C_1
  imuConfig.transport_config.speed = I2C_400KHZ
  imuConfig.transport_config.scl = D11()
  imuConfig.transport_config.sda = D12()
  imuConfig.transport_config.address = ICM20948_I2CADDR_DEFAULT
  
  startLog()
  printLine("ICM20948 IMU Demo")
  printLine()
  
  # Initialize IMU
  let initResult = imu.init(imuConfig)
  if initResult != ICM20948_OK:
    printLine("ERROR: IMU initialization failed!")
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  
  printLine("IMU initialized")
  
  # Setup magnetometer
  let magResult = imu.setupMag()
  if magResult != ICM20948_OK:
    printLine("WARNING: Magnetometer setup failed")
  else:
    printLine("Magnetometer ready")
  
  printLine()
  printLine("Motion controls:")
  printLine("  Tilt X/Y -> Filter cutoff")
  printLine("  Rotation Z -> Resonance")
  printLine("  Heading -> Dry/Wet mix")
  printLine()
  
  # Start audio processing
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  daisy.startAudio(audioCallback)
  
  var ledState = false
  var loopCount = 0'u32
  
  while true:
    # Update IMU readings
    imu.process()
    
    # Get accelerometer data (for tilt sensing)
    let accel = imu.getAccelVect()
    let accelMag = sqrt(accel.x * accel.x + accel.y * accel.y)
    
    # Map tilt to filter cutoff (100Hz to 10kHz)
    cutoff = mapRange(accelMag, 0.0'f32, 2.0'f32, 100.0'f32, 10000.0'f32)
    
    # Get gyroscope data (for rotation sensing)
    let gyro = imu.getGyroVect()
    
    # Map Z-axis rotation to resonance
    resonance = mapRange(abs(gyro.z), 0.0'f32, 250.0'f32, 0.1'f32, 0.95'f32)
    
    # Get magnetometer data (for heading)
    let mag = imu.getMagVect()
    let heading = arctan2(mag.y, mag.x) * 180.0'f32 / PI
    
    # Map heading to mix (-180 to 180 degrees -> 0 to 1)
    mix = mapRange(heading, -180.0'f32, 180.0'f32, 0.0'f32, 1.0'f32)
    
    # Detect motion by comparing acceleration magnitude
    let motionDelta = abs(accelMag - lastAccelMag)
    lastAccelMag = accelMag
    
    # Blink LED on significant motion
    if motionDelta > 0.1'f32:
      ledState = true
    else:
      ledState = false
    
    daisy.setLed(ledState)
    
    # Print debug info every 100 loops (~1 second at 10ms delay)
    inc loopCount
    if loopCount mod 100 == 0:
      print("Accel: ")
      print(accel.x.float)
      print(", ")
      print(accel.y.float)
      print(", ")
      print(accel.z.float)
      print(" | Gyro: ")
      print(gyro.x.float)
      print(", ")
      print(gyro.y.float)
      print(", ")
      print(gyro.z.float)
      print(" | Heading: ")
      print(heading.float)
      print(" | Cutoff: ")
      print(cutoff.int)
      printLine("Hz")
    
    daisy.delay(10)  # Update at ~100Hz

when isMainModule:
  main()
