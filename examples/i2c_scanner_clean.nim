## I2C Scanner Example - Clean API
import panicoverride
## 
## Scans the I2C bus for connected devices

import ../src/libdaisy
import ../src/libdaisy_i2c
import ../src/libdaisy_serial
useDaisyNamespace()


proc printHex(val: uint8) =
  const hexChars = "0123456789ABCDEF"
  let high = hexChars[(val shr 4) and 0x0F]
  let low = hexChars[val and 0x0F]
  print("0x")
  print($high)
  print($low)

proc main() =
  var daisy = initDaisy()
  
  # Initialize I2C on pins D11 (SCL) and D12 (SDA)
  var i2c = initI2C(I2C_1, D11(), D12(), I2C_400KHZ)
  
  startLog()
  printLine("I2C Scanner")
  printLine("Scanning bus...")
  printLine()
  
  while true:
    let devices = i2c.scan()
    
    if devices.len == 0:
      printLine("No I2C devices found")
    else:
      print("Found ")
      print(devices.len)
      printLine(" device(s):")
      
      for addr in devices:
        print("  ")
        printHex(addr)
        
        # Print device name if known
        case addr
        of I2C_ADDR_SSD1306, I2C_ADDR_SSD1306_ALT:
          print(" - SSD1306 OLED")
        of I2C_ADDR_MPU6050:  # Also DS3231 (same address 0x68)
          print(" - MPU6050 IMU / DS3231 RTC")
        of I2C_ADDR_BMP280, I2C_ADDR_BMP280_ALT:
          print(" - BMP280 Sensor")
        of I2C_ADDR_PCF8574:  # Also MCP23017 (same address 0x20)
          print(" - PCF8574/MCP23017 I/O")
        of I2C_ADDR_ADS1115:
          print(" - ADS1115 ADC")
        of I2C_ADDR_AT24C32:
          print(" - AT24C32 EEPROM")
        else: discard
        
        printLine()
    
    printLine()
    daisy.delay(5000)  # Scan every 5 seconds

when isMainModule:
  main()
