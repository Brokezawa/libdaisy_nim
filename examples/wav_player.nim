## WAV File Player
##
## This example demonstrates streaming WAV file playback from SD card.
## Features:
## - Load and play WAV files from SD card
## - Variable playback speed control
## - Looping support
## - Position tracking
##
## Hardware Requirements:
## - Daisy Seed
## - SD card with FAT32 filesystem
## - WAV file named "sample.wav" on SD card (16-bit PCM recommended)
##
## Controls:
## - File plays automatically on startup
## - LED blinks to show playback status

{.define: useWavPlayer.}
{.define: useSDMMC.}

import ../src/libdaisy
import ../src/sys/sdmmc as sd
import ../src/ui/wavplayer
useDaisyNamespace()

var
  daisy: DaisySeed
  sd_card: sd.SDMMCHandler
  player: WavPlayer4K  # 4KB workspace
  isPlaying = false

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Audio callback - streams samples from WAV file
  for i in 0..<size:
    # Stream audio (2 channels)
    var samples: array[2, cfloat]
    discard player.stream(samples[0].addr, 2)
    
    # Output to both channels
    output[0][i] = samples[0]
    output[1][i] = samples[1]

proc main() =
  # Initialize Daisy hardware
  daisy = initDaisy()
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  
  # Initialize SD card
  var sdConfig: SdmmcConfig
  sdConfig.speed = SD_STANDARD
  sdConfig.width = SD_BITS_4
  sdConfig.clock_powersave = false
  
  if sd_card.init(sdConfig) != SD_OK:
    # SD card init failed - blink rapidly
    while true:
      daisy.setLed(true)
      daisy.delay(100)
      daisy.setLed(false)
      daisy.delay(100)
  
  # Mount filesystem
  var fs: FATFS
  if f_mount(addr fs, "", 1) != FR_OK:
    # Mount failed - blink slowly
    while true:
      daisy.setLed(true)
      daisy.delay(500)
      daisy.setLed(false)
      daisy.delay(500)
  
  # Initialize WAV player with file
  let result = player.init("sample.wav")
  if result != WavPlayerResult.Ok:
    # File not found or error - solid LED
    daisy.setLed(true)
    while true:
      daisy.delay(1000)
  
  # Configure playback
  player.setLooping(true)  # Loop the file
  player.setPlaybackSpeedRatio(1.0)  # Normal speed
  player.play()  # Start playback
  isPlaying = true
  
  # Start audio processing
  daisy.startAudio(audioCallback)
  
  # Main loop - refill buffer and blink LED
  var ledState = false
  var counter = 0
  
  while true:
    # Refill WAV player buffer (CRITICAL - must be called regularly)
    let prepResult = player.prepare()
    
    # Blink LED to show playback is active
    counter += 1
    if counter >= 500:
      counter = 0
      ledState = not ledState
      daisy.setLed(ledState)
    
    # Small delay
    daisy.delay(1)

when isMainModule:
  main()
