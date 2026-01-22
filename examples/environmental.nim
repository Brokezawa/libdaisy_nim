## Environmental Monitoring Demo
##
## Demonstrates DPS310 pressure sensor and TLV493D magnetic sensor
## Monitors environmental conditions and magnetic fields
##
## Hardware:
##   - Daisy Seed
##   - DPS310 pressure sensor on I2C
##   - TLV493D magnetic sensor on I2C
##   - I2C connections: SCL=D11 (PB8), SDA=D12 (PB9)
##
## Features:
##   - Barometric pressure monitoring
##   - Altitude calculation
##   - Temperature sensing (from both sensors)
##   - 3D magnetic field measurement
##   - Serial output of all readings

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/libdaisy_serial
import ../src/dev/dps310
import ../src/dev/tlv493d
import std/math
useDaisyNamespace()


const
  SEA_LEVEL_PRESSURE = 1013.25'f32  # Standard sea level pressure in hPa

var
  pressureSensor: Dps310I2C
  magSensor: Tlv493dI2C
  pressure = 0.0'f32
  temperature = 0.0'f32
  altitude = 0.0'f32
  magX = 0.0'f32
  magY = 0.0'f32
  magZ = 0.0'f32

proc calculateAltitude(pressure, seaLevelPressure: float32): float32 =
  ## Calculate altitude from pressure using barometric formula
  ## Returns altitude in meters
  result = 44330.0'f32 * (1.0'f32 - pow(pressure / seaLevelPressure, 0.1903'f32))

proc main() =
  var daisy = initDaisy()
  
  startLog()
  printLine("Environmental Monitoring Demo")
  printLine("==============================")
  printLine()
  
  # Initialize DPS310 pressure sensor
  var pressureConfig: Dps310I2CConfig
  pressureConfig.transport_config.periph = I2C_1
  pressureConfig.transport_config.speed = I2C_400KHZ
  pressureConfig.transport_config.scl = D11()
  pressureConfig.transport_config.sda = D12()
  pressureConfig.transport_config.address = DPS310_I2CADDR_DEFAULT
  
  let pressureInit = pressureSensor.init(pressureConfig)
  if pressureInit != DPS310_OK:
    printLine("ERROR: DPS310 initialization failed!")
  else:
    printLine("DPS310 pressure sensor initialized")
    
    # Configure pressure and temperature measurement
    pressureSensor.configurePressure(DPS310_8HZ, DPS310_64SAMPLES)
    pressureSensor.configureTemperature(DPS310_8HZ, DPS310_64SAMPLES)
  
  # Initialize TLV493D magnetic sensor
  var magConfig: Tlv493dConfig
  magConfig.transport_config.periph = I2C_1
  magConfig.transport_config.speed = I2C_400KHZ
  magConfig.transport_config.scl = D11()
  magConfig.transport_config.sda = D12()
  magConfig.transport_config.address = TLV493D_ADDRESS1
  
  let magInit = magSensor.init(magConfig)
  if magInit != TLV493D_OK:
    printLine("ERROR: TLV493D initialization failed!")
  else:
    printLine("TLV493D magnetic sensor initialized")
    magSensor.setAccessMode(FASTMODE)  # Fast mode for continuous readings
  
  printLine()
  printLine("Monitoring environmental conditions...")
  printLine()
  
  var loopCount = 0'u32
  var ledState = false
  
  while true:
    # Update pressure sensor
    if pressureInit == DPS310_OK:
      pressureSensor.process()
      pressure = pressureSensor.getPressure()
      temperature = pressureSensor.getTemperature()
      altitude = calculateAltitude(pressure, SEA_LEVEL_PRESSURE)
    
    # Update magnetic sensor
    if magInit == TLV493D_OK:
      magSensor.updateData()
      magX = magSensor.getX()
      magY = magSensor.getY()
      magZ = magSensor.getZ()
    
    # Print readings every 100 loops (~1 second at 10ms delay)
    inc loopCount
    if loopCount mod 100 == 0:
      printLine("--- Environmental Data ---")
      
      if pressureInit == DPS310_OK:
        print("Pressure:    ")
        print(pressure.float)
        printLine(" hPa")
        
        print("Altitude:    ")
        print(altitude.float)
        printLine(" m")
        
        print("Temperature: ")
        print(temperature.float)
        printLine(" C")
      else:
        printLine("Pressure sensor: OFFLINE")
      
      printLine()
      
      if magInit == TLV493D_OK:
        print("Magnetic X:  ")
        print(magX.float)
        printLine(" mT")
        
        print("Magnetic Y:  ")
        print(magY.float)
        printLine(" mT")
        
        print("Magnetic Z:  ")
        print(magZ.float)
        printLine(" mT")
        
        # Calculate field magnitude
        let magnitude = sqrt(magX * magX + magY * magY + magZ * magZ)
        print("Field Total: ")
        print(magnitude.float)
        printLine(" mT")
        
        # Calculate azimuth and polar angles
        let azimuth = magSensor.getAzimuth()
        let polar = magSensor.getPolar()
        
        print("Azimuth:     ")
        print(azimuth.float)
        printLine(" deg")
        
        print("Polar:       ")
        print(polar.float)
        printLine(" deg")
      else:
        printLine("Magnetic sensor: OFFLINE")
      
      printLine()
      
      # Toggle LED to show activity
      ledState = not ledState
      daisy.setLed(ledState)
    
    # Additional detailed output every 10 seconds
    if loopCount mod 1000 == 0:
      printLine("=============================")
      printLine("10-Second Summary:")
      
      if pressureInit == DPS310_OK:
        # Pressure trend analysis (compare to sea level)
        let pressureDiff = pressure - SEA_LEVEL_PRESSURE
        if pressureDiff > 5.0'f32:
          printLine("  Weather: High pressure system")
        elif pressureDiff < -5.0'f32:
          printLine("  Weather: Low pressure system")
        else:
          printLine("  Weather: Normal pressure")
      
      if magInit == TLV493D_OK:
        # Magnetic field analysis
        let magnitude = sqrt(magX * magX + magY * magY + magZ * magZ)
        if magnitude > 0.1'f32:
          printLine("  Magnetic: Strong field detected")
        elif magnitude > 0.05'f32:
          printLine("  Magnetic: Moderate field")
        else:
          printLine("  Magnetic: Weak field")
      
      printLine("=============================")
      printLine()
    
    daisy.delay(10)  # Update at ~100Hz

when isMainModule:
  main()
