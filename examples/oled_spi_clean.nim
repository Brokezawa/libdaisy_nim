## OLED SPI Example
## 
## Demonstrates OLED display usage via SPI (faster than I2C).
## Good for animations and high-refresh applications.
##
## Hardware setup:
## - OLED SCK  -> PG11 (default)
## - OLED MOSI -> PB5  (default)
## - OLED CS   -> PG10 (default)
## - OLED DC   -> PB4  (default)
## - OLED RST  -> PB15 (default)

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_oled

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Initialize 128x64 OLED display via SPI
  # SPI is faster than I2C - good for animations
  var display = initOledSpi(128, 64)
  
  # Clear screen
  display.fill(false)
  
  # Draw border
  display.drawRect(0, 0, display.width, display.height, true)
  
  # Draw diagonal lines for speed test
  for i in 0..<8:
    display.drawLine(0, i * 8, display.width - 1, display.height - 1 - i * 8, true)
  
  display.update()
  
  # Animated expanding/contracting circle
  var radius = 5
  var growing = true
  let centerX = display.width div 2
  let centerY = display.height div 2
  let maxRadius = min(centerX, centerY) - 5
  
  while true:
    # Clear previous frame
    display.fill(false)
    
    # Draw border
    display.drawRect(0, 0, display.width, display.height, true)
    
    # Draw expanding/contracting circle
    display.drawCircle(centerX, centerY, radius, true)
    
    # Draw some decorative corners
    display.fillRect(0, 0, 5, 5, true)
    display.fillRect(display.width - 5, 0, 5, 5, true)
    display.fillRect(0, display.height - 5, 5, 5, true)
    display.fillRect(display.width - 5, display.height - 5, 5, 5, true)
    
    display.update()
    
    # Update radius
    if growing:
      inc radius
      if radius >= maxRadius:
        growing = false
    else:
      dec radius
      if radius <= 5:
        growing = true
    
    hw.delay(30)  # Smooth animation at ~33 FPS

when isMainModule:
  main()
