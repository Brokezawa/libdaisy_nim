## OLED Graphics Example
## 
## Demonstrates various drawing functions on the OLED display.
## Shows rectangles, circles, lines, and patterns.

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_oled

useDaisyNamespace()

proc main() =
  var hw = initDaisy()
  
  # Initialize OLED display - now works with any size!
  var display = initOledI2c(128, 64)
  
  var frame = 0
  
  while true:
    # Clear display
    display.fill(false)
    
    let pattern = frame mod 4
    
    case pattern
    of 0:
      # Pattern 1: Concentric circles
      let centerX = display.width div 2
      let centerY = display.height div 2
      let maxRadius = min(centerX, centerY) - 2
      for r in countup(5, maxRadius, 5):
        display.drawCircle(centerX, centerY, r, true)
    
    of 1:
      # Pattern 2: Grid
      for i in countup(0, display.width - 1, 16):
        display.drawLine(i, 0, i, display.height - 1, true)
      for i in countup(0, display.height - 1, 16):
        display.drawLine(0, i, display.width - 1, i, true)
    
    of 2:
      # Pattern 3: Diagonal lines
      for i in 0..<8:
        display.drawLine(i * 16, 0, display.width - 1, display.height - 1 - i * 8, true)
        display.drawLine(0, i * 8, display.width - 1 - i * 16, display.height - 1, true)
    
    else:
      # Pattern 4: Rectangles
      for i in 0..<4:
        let size = 20 + i * 15
        let x = display.width div 2 - size div 2
        let y = display.height div 2 - (size * display.height) div (display.width * 2)
        display.drawRect(x, y, size, (size * display.height) div display.width, true)
    
    # Draw border
    display.drawRect(0, 0, display.width, display.height, true)
    
    # Update display
    display.update()
    
    inc frame
    hw.delay(2000)  # Change pattern every 2 seconds

when isMainModule:
  main()
