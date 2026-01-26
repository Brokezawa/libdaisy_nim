## Advanced Logging Example
## ========================
##
## Demonstrates USB logging with performance measurement using system timing.
##
## This example shows:
## - USB logger for debug output
## - System timing functions (getUs, getNow)
## - Performance profiling
## - Nim string formatting
## - Structured logging patterns
##
## Hardware: Any Daisy board (tested on Daisy Seed)
##
## Usage:
## 1. Build and flash: `make TARGET=advanced_logging program-dfu`
## 2. Connect via USB serial (any terminal, USB CDC doesn't use baud rate)
## 3. Watch performance metrics and heartbeat messages
##
## Output:
## - System info on startup
## - LED toggle timing measurements
## - Memory usage stats
## - Performance metrics every 5 seconds

import ../src/libdaisy
import ../src/libdaisy_logger
import ../src/libdaisy_system
import std/strformat

useDaisyNamespace()

# ============================================================================
# Configuration
# ============================================================================

const
  HEARTBEAT_INTERVAL_MS = 5000  ## How often to print stats
  LED_BLINK_MS = 500            ## LED toggle period

# ============================================================================
# Global State
# ============================================================================

var
  hw: DaisySeed
  ledState: bool = false
  loopCount: uint32 = 0
  lastHeartbeat: uint32 = 0
  lastLedToggle: uint32 = 0

# ============================================================================
# Performance Profiling Helpers
# ============================================================================

proc measureTime(name: string, operation: proc()) =
  ## Measure and log execution time of an operation
  let startTime = getUs()
  operation()
  let endTime = getUs()
  let elapsed = endTime - startTime
  
  UsbLogger.print("  ")
  UsbLogger.print(cstring(name))
  UsbLogger.print(": ")
  UsbLogger.print(cstring($elapsed))
  UsbLogger.printLine(" us")

# ============================================================================
# Application Logic
# ============================================================================

proc printSystemInfo() =
  ## Print detailed system information
  UsbLogger.printLine("=============================")
  UsbLogger.printLine("  Advanced Logging Demo")
  UsbLogger.printLine("=============================")
  UsbLogger.printLine("")
  
  # Clock frequencies
  UsbLogger.printLine("System Clocks:")
  let sysclk = getSysClkFreq()
  let hclk = getHClkFreq()
  
  UsbLogger.print("  CPU:  ")
  UsbLogger.print(cstring($sysclk))
  UsbLogger.printLine(" Hz")
  
  UsbLogger.print("  AHB:  ")
  UsbLogger.print(cstring($hclk))
  UsbLogger.printLine(" Hz")
  UsbLogger.printLine("")

proc toggleLed() =
  ## Toggle LED with timing measurement
  ledState = not ledState
  hw.setLed(ledState)

proc printHeartbeat() =
  ## Print periodic status update
  let now = getNow()
  let uptime = now div 1000  # Convert to seconds
  
  UsbLogger.printLine("")
  UsbLogger.printLine("--- Heartbeat ---")
  
  # Uptime
  UsbLogger.print("Uptime: ")
  UsbLogger.print(cstring($uptime))
  UsbLogger.printLine(" seconds")
  
  # Loop count
  UsbLogger.print("Loops: ")
  UsbLogger.print(cstring($loopCount))
  UsbLogger.printLine("")
  
  # Performance test
  UsbLogger.printLine("Performance:")
  measureTime("LED toggle"):
    toggleLed()
  
  measureTime("delay(1)"):
    delay(1)
  
  UsbLogger.printLine("")

# ============================================================================
# Initialization
# ============================================================================

proc init() =
  ## Initialize hardware and logging
  hw = initDaisy()
  
  # Start USB logger (non-blocking)
  UsbLogger.startLog(false)
  
  # Small delay to ensure USB is ready
  delay(100)
  
  # Print system info
  printSystemInfo()
  
  # Initialize timing
  lastHeartbeat = getNow()
  lastLedToggle = getNow()

# ============================================================================
# Main Program
# ============================================================================

proc main() =
  ## Main entry point
  init()
  
  UsbLogger.printLine("Starting main loop...")
  UsbLogger.printLine("LED blinks at 500ms, stats every 5 seconds")
  UsbLogger.printLine("")
  
  # Main loop
  while true:
    let now = getNow()
    
    # Toggle LED periodically
    if now - lastLedToggle >= LED_BLINK_MS:
      toggleLed()
      lastLedToggle = now
    
    # Print heartbeat periodically
    if now - lastHeartbeat >= HEARTBEAT_INTERVAL_MS:
      printHeartbeat()
      lastHeartbeat = now
    
    # Increment loop counter
    loopCount += 1
    
    # Small delay to avoid busy-waiting
    delay(10)

when isMainModule:
  main()
