## SPI Basic Example
import panicoverride
##
## Basic SPI communication example

import ../src/libdaisy
import ../src/per/spi
import ../src/per/uart
useDaisyNamespace()


proc main() =
  var daisy = initDaisy()
  
  # Initialize SPI on SPI1 pins: D8 (SCK), D9 (MISO), D10 (MOSI)
  var spi = initSPI(SPI_1, D8(), D9(), D10())
  
  startLog()
  printLine("SPI Basic Example")
  printLine()
  
  while true:
    # Write some bytes
    let writeResult = spi.write([0x01'u8, 0x02, 0x03, 0x04])
    
    if writeResult == SPI_OK:
      printLine("Write: OK")
    else:
      printLine("Write: ERROR")
    
    # Read some bytes
    var readBuffer: array[4, uint8]
    let readResult = spi.read(readBuffer)
    
    if readResult == SPI_OK:
      print("Read: ")
      for b in readBuffer:
        print(int(b))
        print(" ")
      printLine()
    else:
      printLine("Read: ERROR")
    
    # Full-duplex transfer
    var rxData: array[4, uint8]
    let xferResult = spi.transfer([0xAA'u8, 0xBB, 0xCC, 0xDD], rxData)
    
    if xferResult == SPI_OK:
      print("Transfer RX: ")
      for b in rxData:
        print(int(b))
        print(" ")
      printLine()
    
    daisy.delay(1000)

when isMainModule:
  main()
