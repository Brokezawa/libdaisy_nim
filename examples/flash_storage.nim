## QSPI Flash Storage Example - Simplified
## =========================================
##
## Demonstrates basic QSPI flash operations.
## This is a minimal example to verify compilation.

import ../src/libdaisy
import ../src/libdaisy_qspi
import ../src/libdaisy_serial

useDaisyNamespace()

proc main() =
  # Initialize
  var daisy = initDaisy()
  startLog()
  daisy.delay(100)
  
  printLine("QSPI Flash Storage Example")
  printLine("==========================")
  
  # Configure QSPI
  var config = libdaisy_qspi.QSPIConfig(
    device: libdaisy_qspi.QSPIDevice.IS25LP064A,
    mode: libdaisy_qspi.QSPIMode.INDIRECT_POLLING
  )
  
  # Initialize QSPI
  var qspi: libdaisy_qspi.QSPIHandle
  print("Initializing QSPI...")
  
  if qspi.init(config) != libdaisy_qspi.QSPIResult.OK:
    printLine(" FAILED")
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  
  printLine(" OK")
  
  # Erase a sector
  print("Erasing sector 0...")
  if qspi.eraseSector(0) != libdaisy_qspi.QSPIResult.OK:
    printLine(" FAILED")
  else:
    printLine(" OK")
  
  # Write test data
  var testData: array[256, uint8]
  for i in 0..<256:
    testData[i] = uint8(i)
  
  print("Writing test pattern...")
  if qspi.writePage(0, 256, addr testData[0]) != libdaisy_qspi.QSPIResult.OK:
    printLine(" FAILED")
  else:
    printLine(" OK")
  
  # Read back
  let readData = cast[ptr UncheckedArray[uint8]](qspi.getData(0))
  
  # Verify
  var ok = true
  for i in 0..<256:
    if readData[i] != testData[i]:
      ok = false
      break
  
  if ok:
    printLine("Verification: PASSED")
  else:
    printLine("Verification: FAILED")
  
  # Success
  printLine("Done!")
  daisy.setLed(true)
  
  while true:
    daisy.delay(1000)

when isMainModule:
  main()
