## QSPI Flash Storage Demo
##
## This example demonstrates reading and writing data to QSPI flash memory.
## Features:
## - Erase sectors of QSPI flash
## - Write data to flash
## - Read data back from flash
## - Verify written data
##
## Hardware Requirements:
## - Daisy Seed with QSPI flash (IS25LP064A - 8MB)
##
## Operation:
## - Erases first sector (4KB)
## - Writes test pattern to flash
## - Reads back and verifies data
## - LED indicates success/failure
##
## Note: This example uses INDIRECT_POLLING mode for read/write access.
## For executing code from QSPI, use MEMORY_MAPPED mode instead.

{.define: useQSPI.}

import ../src/libdaisy
import ../src/libdaisy_qspi as qspi_module  # Use qualified import to avoid ambiguity
useDaisyNamespace()

const
  TEST_ADDR = 0'u32  # Start at beginning of flash
  TEST_SIZE = 256'u32  # One page

var
  daisy: DaisySeed
  qspi: qspi_module.QSPIHandle
  testData: array[256, uint8]
  readBuffer: array[256, uint8]

proc fillTestPattern() =
  ## Fill test buffer with a pattern
  for i in 0..<256:
    testData[i] = uint8(i and 0xFF)

proc verifyData(): bool =
  ## Verify that read data matches written data
  for i in 0..<256:
    if readBuffer[i] != testData[i]:
      return false
  return true

proc blinkPattern(count: int, fast: bool = false) =
  ## Blink LED a specific number of times
  let delayTime = if fast: 100 else: 300
  for i in 0..<count:
    daisy.setLed(true)
    daisy.delay(delayTime)
    daisy.setLed(false)
    daisy.delay(delayTime)
  daisy.delay(500)

proc main() =
  # Initialize hardware
  daisy = initDaisy()
  
  # Initialize QSPI in indirect polling mode (for read/write)
  var config = QSPIConfig(
    device: QSPIDevice.IS25LP064A,  # 8MB flash on Daisy Seed
    mode: QSPIMode.INDIRECT_POLLING
  )
  
  if qspi.init(config) != QSPIResult.OK:
    # QSPI init failed - rapid blink
    while true:
      blinkPattern(5, fast = true)
  
  # Fill test pattern
  fillTestPattern()
  
  # Step 1: Erase the sector
  # Must erase before writing (sets all bits to 1)
  if qspi.eraseSector(TEST_ADDR) != QSPIResult.OK:
    # Erase failed - 2 blinks
    while true:
      blinkPattern(2)
  
  # Small delay after erase
  daisy.delay(100)
  
  # Step 2: Write test data to flash
  if qspi.writePage(TEST_ADDR, TEST_SIZE, testData[0].addr) != QSPIResult.OK:
    # Write failed - 3 blinks
    while true:
      blinkPattern(3)
  
  # Small delay after write
  daisy.delay(100)
  
  # Step 3: Read data back
  # Get pointer to flash memory
  let flashPtr = cast[ptr UncheckedArray[uint8]](qspi.getData(TEST_ADDR))
  
  # Copy data from flash to read buffer
  for i in 0..<256:
    readBuffer[i] = flashPtr[i]
  
  # Step 4: Verify data
  if verifyData():
    # Success! - Long blink followed by steady on
    for i in 0..2:
      daisy.setLed(true)
      daisy.delay(500)
      daisy.setLed(false)
      daisy.delay(500)
    
    # Leave LED on to indicate success
    daisy.setLed(true)
  else:
    # Verification failed - 4 blinks
    while true:
      blinkPattern(4)
  
  # Success loop - just keep LED on
  while true:
    daisy.delay(1000)

when isMainModule:
  main()
