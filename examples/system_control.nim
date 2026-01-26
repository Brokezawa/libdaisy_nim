## System Control Example
## ======================
##
## Demonstrates system-level features:
## - Clock frequency information
## - Timing functions (milliseconds, microseconds, ticks)
## - Delay demonstrations
## - Memory region detection
##
## Hardware: Any Daisy board (tested on Daisy Seed)
##
## Usage:
## 1. Build and flash: `make TARGET=system_control program-dfu`
## 2. Connect via USB serial (115200 baud, though rate doesn't matter for USB CDC)
## 3. Watch system information printed on startup
## 4. LED blinks at 1 Hz heartbeat

import ../src/libdaisy
import ../src/libdaisy_system
import ../src/libdaisy_logger

useDaisyNamespace()

# UsbLogger is a built-in type alias, no need to define

proc printSystemInfo() =
  ## Print detailed system clock information
  UsbLogger.printLine("=")
  UsbLogger.printLine("=== Daisy System Control ===")
  UsbLogger.printLine("=")
  UsbLogger.printLine("")
  
  # Clock frequencies
  UsbLogger.printLine("Clock Frequencies:")
  UsbLogger.printLine("-----------------")
  
  let sysclk = getSysClkFreq()
  let hclk = getHClkFreq()
  let pclk1 = getPClk1Freq()
  let pclk2 = getPClk2Freq()
  let tickFreq = getTickFreq()
  
  # Print frequencies (manual string building for embedded)
  UsbLogger.print("System Clock: ")
  UsbLogger.print(cstring($sysclk))
  UsbLogger.printLine(" Hz")
  
  UsbLogger.print("AHB Clock:    ")
  UsbLogger.print(cstring($hclk))
  UsbLogger.printLine(" Hz")
  
  UsbLogger.print("APB1 Clock:   ")
  UsbLogger.print(cstring($pclk1))
  UsbLogger.printLine(" Hz")
  
  UsbLogger.print("APB2 Clock:   ")
  UsbLogger.print(cstring($pclk2))
  UsbLogger.printLine(" Hz")
  
  UsbLogger.print("SysTick Freq: ")
  UsbLogger.print(cstring($tickFreq))
  UsbLogger.printLine(" Hz")
  UsbLogger.printLine("")
  
  # Memory region
  UsbLogger.printLine("Program Location:")
  UsbLogger.printLine("----------------")
  
  let region = getProgramMemoryRegion()
  case region
  of INTERNAL_FLASH:
    UsbLogger.printLine("Running from: INTERNAL_FLASH (128KB)")
  of QSPI:
    UsbLogger.printLine("Running from: QSPI Flash (8MB)")
  of ITCMRAM:
    UsbLogger.printLine("Running from: ITCM RAM (64KB)")
  of DTCMRAM:
    UsbLogger.printLine("Running from: DTCM RAM (128KB)")
  of SRAM_D1:
    UsbLogger.printLine("Running from: SRAM D1 (512KB)")
  of SRAM_D2:
    UsbLogger.printLine("Running from: SRAM D2 (288KB)")
  of SRAM_D3:
    UsbLogger.printLine("Running from: SRAM D3 (64KB)")
  of SDRAM:
    UsbLogger.printLine("Running from: External SDRAM")
  else:
    UsbLogger.printLine("Running from: UNKNOWN")
  
  UsbLogger.printLine("")
  
  # Bootloader version
  UsbLogger.printLine("Bootloader:")
  UsbLogger.printLine("-----------")
  
  let bootVer = getBootloaderVersion()
  case bootVer
  of NONE:
    UsbLogger.printLine("Daisy Bootloader: NOT INSTALLED")
    UsbLogger.printLine("(Use STM32 DFU mode only)")
  of LT_v6_0:
    UsbLogger.printLine("Daisy Bootloader: < v6.0 (legacy)")
  of v6_0:
    UsbLogger.printLine("Daisy Bootloader: v6.0")
  of v6_1:
    UsbLogger.printLine("Daisy Bootloader: v6.1+")
  else:
    UsbLogger.printLine("Daisy Bootloader: UNKNOWN")
  
  UsbLogger.printLine("")

proc demonstrateDelays() =
  ## Demonstrate different delay mechanisms
  UsbLogger.printLine("Delay Demonstration:")
  UsbLogger.printLine("-------------------")
  
  # 1. Millisecond delay
  UsbLogger.printLine("Testing 500ms delay...")
  let startMs = getNow()
  delay(500)
  let endMs = getNow()
  let elapsedMs = endMs - startMs
  
  UsbLogger.print("Actual elapsed: ")
  UsbLogger.print(cstring($elapsedMs))
  UsbLogger.printLine(" ms")
  
  # 2. Microsecond delay
  UsbLogger.printLine("Testing 1000us delay...")
  let startUs = getUs()
  delayUs(1000)
  let endUs = getUs()
  let elapsedUs = endUs - startUs
  
  UsbLogger.print("Actual elapsed: ")
  UsbLogger.print(cstring($elapsedUs))
  UsbLogger.printLine(" us")
  
  # 3. Tick delay (10,000 ticks)
  UsbLogger.printLine("Testing 10000 tick delay...")
  let startTicks = getTick()
  delayTicks(10000)
  let endTicks = getTick()
  let elapsedTicks = endTicks - startTicks
  
  UsbLogger.print("Actual elapsed: ")
  UsbLogger.print(cstring($elapsedTicks))
  UsbLogger.printLine(" ticks")
  
  UsbLogger.printLine("")

proc main() =
  # Initialize hardware
  var hw = initDaisy()
  
  # Initialize logger (don't wait for PC connection)
  UsbLogger.startLog(false)
  
  # Small delay to let USB enumerate
  delay(500)
  
  # Print system information
  printSystemInfo()
  
  # Demonstrate delay functions
  demonstrateDelays()
  
  # Instructions
  UsbLogger.printLine("Instructions:")
  UsbLogger.printLine("------------")
  UsbLogger.printLine("- LED blinks at 1 Hz")
  UsbLogger.printLine("- Heartbeat printed every 10 seconds")
  UsbLogger.printLine("")
  UsbLogger.printLine("Starting main loop...")
  UsbLogger.printLine("")
  
  var ledState = false
  var lastBlinkTime = getNow()
  var loopCounter: uint32 = 0
  
  # Main loop
  while true:
    let now = getNow()
    
    # Blink LED at 1 Hz
    if now - lastBlinkTime >= 500:
      ledState = not ledState
      hw.setLed(ledState)
      lastBlinkTime = now
      
      # Print heartbeat every 10 seconds
      loopCounter += 1
      if loopCounter mod 20 == 0:
        UsbLogger.print("Heartbeat: uptime = ")
        UsbLogger.print(cstring($(now div 1000)))
        UsbLogger.printLine(" seconds")
    
    # Small delay to prevent tight loop
    delay(10)

when isMainModule:
  main()
