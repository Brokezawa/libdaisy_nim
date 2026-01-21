## WAV File Recorder
##
## This example demonstrates real-time audio recording to SD card.
## Features:
## - Record audio input to WAV file
## - 16-bit PCM format at 48kHz
## - Automatic file finalization
## - Recording status indication
##
## Hardware Requirements:
## - Daisy Seed
## - SD card with FAT32 filesystem
## - Audio input source
##
## Controls:
## - Recording starts automatically on boot
## - Press user button to stop and save recording
## - LED indicates recording status (on = recording)
##
## Output:
## - Creates "recording.wav" on SD card

{.define: useWavWriter.}
{.define: useSDMMC.}
{.define: useSwitch.}

import ../src/libdaisy
import ../src/sys/sdmmc as sd
import ../src/ui/wavwriter
import ../src/hid/switch
useDaisyNamespace()

var
  daisy: DaisySeed
  sd_card: sd.SDMMCHandler
  writer: WavWriter32K  # 32KB transfer size
  stopButton: Switch
  recording = false

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Audio callback - record input and pass through to output
  for i in 0..<size:
    # Record stereo input
    var frame = [input[0][i], input[1][i]]
    if recording:
      writer.sample(frame[0].addr)
    
    # Pass through to output (monitor)
    output[0][i] = input[0][i]
    output[1][i] = input[1][i]

proc main() =
  # Initialize Daisy hardware
  daisy = initDaisy()
  daisy.setSampleRate(SAI_48KHZ)
  daisy.setBlockSize(48)
  
  # Initialize button (user button on Daisy Seed)
  stopButton.init(getPin(28))  # Pin 28 = user button
  
  # Initialize SD card
  var sdConfig = newSdmmcConfig()
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
  
  # Configure WAV writer
  var config = createConfig(
    samplerate = 48000.0,
    channels = 2,
    bitspersample = 16
  )
  writer.init(config)
  
  # Open file for recording
  writer.openFile("recording.wav")
  
  if not writer.isRecording():
    # Failed to open file - solid LED
    daisy.setLed(true)
    while true:
      daisy.delay(1000)
  
  recording = true
  daisy.setLed(true)  # LED on = recording
  
  # Start audio processing
  daisy.startAudio(audioCallback)
  
  # Main loop - write to SD card and check for stop button
  while recording:
    # Write buffered audio to SD card (CRITICAL - must be called regularly)
    writer.write()
    
    # Check stop button
    stopButton.debounce()
    if stopButton.risingEdge():
      # Stop recording
      recording = false
      daisy.setLed(false)
      
      # Finalize and close file
      writer.saveFile()
      
      # Blink to indicate save complete
      for i in 0..5:
        daisy.setLed(true)
        daisy.delay(100)
        daisy.setLed(false)
        daisy.delay(100)
    
    # Small delay
    daisy.delay(1)
  
  # Recording stopped - enter idle loop
  while true:
    daisy.delay(1000)

when isMainModule:
  main()
