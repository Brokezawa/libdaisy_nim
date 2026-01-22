## VU Meter Example - DotStar Audio Visualizer
##
## Audio-reactive LED VU meter using DotStar RGB LED strip.
## Displays stereo audio levels with color gradient.

import panicoverride
import ../src/libdaisy
import ../src/libdaisy_spi
import ../src/dev/dotstar

useDaisyNamespace()

const NUM_LEDS = 16

var
  leds: DotStarSpi
  hw: DaisySeed
  peakL, peakR: float32 = 0.0

proc audioCallback(input_buffer, output_buffer: AudioBuffer, size: int) {.cdecl.} =
  ## Process audio and detect peaks
  for i in 0 ..< size:
    # Pass through
    output_buffer[0][i] = input_buffer[0][i]
    output_buffer[1][i] = input_buffer[1][i]
    
    # Track peaks
    let
      absL = abs(input_buffer[0][i])
      absR = abs(input_buffer[1][i])
    if absL > peakL: peakL = absL
    if absR > peakR: peakR = absR

hw.init()

var config: DotStarConfig
config.defaults()
config.num_pixels = NUM_LEDS
config.color_order = GRB

discard leds.init(config)
leds.setAllGlobalBrightness(5)  # Keep brightness low

hw.startAudio(audioCallback)

while true:
  # Decay peaks
  peakL *= 0.95
  peakR *= 0.95
  
  # Calculate VU levels (0-8 LEDs per channel)
  let
    levelL = (peakL * 8.0).int.clamp(0, 8)
    levelR = (peakR * 8.0).int.clamp(0, 8)
  
  # Clear all
  leds.clear()
  
  # Left channel (LEDs 0-7) - Green to Red gradient
  for i in 0 ..< levelL:
    let
      green = (255 * (8 - i) div 8).uint8
      red = (255 * i div 8).uint8
    discard leds.setPixelColor(i.uint16, red, green, 0)
  
  # Right channel (LEDs 8-15) - Blue to Red gradient  
  for i in 0 ..< levelR:
    let
      blue = (255 * (8 - i) div 8).uint8
      red = (255 * i div 8).uint8
    discard leds.setPixelColor((i + 8).uint16, red, 0, blue)
  
  discard leds.show()
  hw.delay(20)  # 50 Hz update rate
