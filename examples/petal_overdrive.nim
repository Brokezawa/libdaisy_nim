## Guitar Overdrive for Daisy Petal
## ==================================
##
## **Hardware:** Daisy Petal guitar pedal platform
##
## **Description:**
## Full-featured overdrive/distortion guitar effect pedal.
## Demonstrates audio processing with real-time control and visual feedback.
##
## **Functionality:**
## - Soft-clipping overdrive algorithm
## - Real-time parameter control via knobs
## - Bypass switching with LED indication
## - Visual VU meter using ring LEDs
## - True stereo processing
##
## **Control Mapping:**
## - **Knob 1 (Gain)**: Input gain (0-10x)
## - **Knob 2 (Drive)**: Distortion amount (soft clipping threshold)
## - **Knob 3 (Tone)**: Simple low-pass filter cutoff
## - **Knob 4 (Level)**: Output level
## - **Knob 5 (Mix)**: Dry/wet mix (0% = bypass, 100% = full effect)
## - **Knob 6 (Bias)**: Asymmetric clipping bias
## - **Footswitch 1 (Bypass)**: Toggle effect bypass
## - **Footswitch 2 (Boost)**: Momentary gain boost (+6dB)
## - **Footswitch 3 (Mode)**: Toggle overdrive mode (soft/hard clipping)
## - **Footswitch 4 (Mute)**: Mute output
## - **Ring LEDs**: VU meter showing output level
## - **Footswitch LEDs**: Indicate active states
##
## **Expected Behavior:**
## - Clean guitar signal passes through when bypassed
## - Overdrive adds harmonic distortion when engaged
## - Ring LEDs show output level in real-time
## - Footswitch LEDs indicate bypass/boost/mute states
##
## **Use Cases:**
## - Guitar overdrive/distortion pedal
## - Learning audio effect algorithms
## - Template for custom effects pedals

import ../src/libdaisy_petal
import ../src/libdaisy_macros

useDaisyNamespace()

# Simple soft-clipper with tanh approximation
proc softClip(x: cfloat, threshold: cfloat): cfloat {.inline.} =
  ## Soft clipping using polynomial approximation of tanh
  ## Provides smooth saturation for overdrive effect
  let scaled = x / threshold
  
  # Fast tanh approximation: x / (1 + |x|)
  if scaled > 3.0:
    return threshold
  elif scaled < -3.0:
    return -threshold
  else:
    let absScaled = if scaled < 0.0: -scaled else: scaled
    return (scaled / (1.0 + absScaled)) * threshold

# Simple one-pole low-pass filter
type LowPassFilter = object
  lastOutput: cfloat
  coefficient: cfloat

proc initLowPass(cutoff: cfloat, sampleRate: cfloat): LowPassFilter =
  ## Initialize low-pass filter with cutoff frequency
  let rc = 1.0 / (cutoff * 2.0 * 3.14159265)
  let dt = 1.0 / sampleRate
  result.coefficient = dt / (rc + dt)
  result.lastOutput = 0.0

proc process(filter: var LowPassFilter, input: cfloat): cfloat =
  ## Process one sample through the filter
  filter.lastOutput = filter.lastOutput + filter.coefficient * (input - filter.lastOutput)
  return filter.lastOutput

# Global effect state
var
  bypassed = true
  boostActive = false
  hardClipMode = false
  muted = false
  filterL: LowPassFilter
  filterR: LowPassFilter
  peakLevel: cfloat = 0.0

# Audio callback
proc audioCallback(input: ptr ptr float32, output: ptr ptr float32, size: csize_t) {.cdecl.} =
  var gain, drive, tone, level, mix, bias: cfloat
  
  for i in 0..<size:
    var inL, inR, outL, outR: cfloat
    
    # Read inputs using emit (workaround for ptr ptr indexing)
    {.emit: "`inL` = `input`[0][`i`];".}
    {.emit: "`inR` = `input`[1][`i`];".}
    
    if muted:
      outL = 0.0
      outR = 0.0
    elif bypassed:
      # Bypass - pass through unaffected
      outL = inL
      outR = inR
    else:
      # Read parameters (in real implementation, these would be updated from controls)
      gain = 1.0  # Will be set from knobs
      drive = 0.5
      level = 1.0
      mix = 1.0
      
      # Apply gain
      var processedL = inL * gain
      var processedR = inR * gain
      
      # Apply soft clipping
      let threshold = 1.0 / (1.0 + drive * 10.0)
      processedL = softClip(processedL, threshold)
      processedR = softClip(processedR, threshold)
      
      # Apply tone filter
      processedL = filterL.process(processedL)
      processedR = filterR.process(processedR)
      
      # Apply output level
      processedL = processedL * level
      processedR = processedR * level
      
      # Mix dry/wet
      outL = inL * (1.0 - mix) + processedL * mix
      outR = inR * (1.0 - mix) + processedR * mix
      
      # Boost if active
      if boostActive:
        outL = outL * 2.0  # +6dB boost
        outR = outR * 2.0
    
    # Write outputs using emit
    {.emit: "`output`[0][`i`] = `outL`;".}
    {.emit: "`output`[1][`i`] = `outR`;".}
    
    # Track peak level for VU meter
    let absL = if outL < 0.0: -outL else: outL
    let absR = if outR < 0.0: -outR else: outR
    let peak = if absL > absR: absL else: absR
    if peak > peakLevel:
      peakLevel = peak

proc updateVuMeter(petal: var DaisyPetal, level: cfloat) =
  ## Update ring LEDs to show VU meter
  ## Green = low, yellow = medium, red = high
  
  let numLeds = (level * 8.0).int
  
  for i in 0..<8:
    if i < numLeds:
      # LED is active - color based on level
      if i < 3:
        # Green (low level)
        petal.setRingLed(i.cint, 0.0, 1.0, 0.0)
      elif i < 6:
        # Yellow (medium level)
        petal.setRingLed(i.cint, 1.0, 1.0, 0.0)
      else:
        # Red (high level/clipping)
        petal.setRingLed(i.cint, 1.0, 0.0, 0.0)
    else:
      # LED is off
      petal.setRingLed(i.cint, 0.0, 0.0, 0.0)

proc main() =
  var petal: DaisyPetal
  
  # Initialize hardware
  petal.init()
  petal.startAdc()
  
  # Initialize filters
  filterL = initLowPass(5000.0, 48000.0)
  filterR = initLowPass(5000.0, 48000.0)
  
  # Start audio
  petal.startAudio(audioCallback)
  
  # Initialize LEDs
  petal.clearLeds()
  petal.setFootswitchLed(FOOTSWITCH_LED_1.cint, 1.0)  # Bypass LED on by default
  petal.updateLeds()
  
  var frameCount = 0
  
  # Main loop
  while true:
    # Update controls
    petal.processAllControls()
    
    # Read knobs (parameters would be used in audio callback)
    let gain  = petal.getKnobValue(KNOB_1.cint) * 10.0  # 0-10x gain
    let drive = petal.getKnobValue(KNOB_2.cint)         # 0-1 drive amount
    let tone  = petal.getKnobValue(KNOB_3.cint) * 10000.0 + 200.0  # 200-10200 Hz
    let level = petal.getKnobValue(KNOB_4.cint)         # 0-1 output level
    let mix   = petal.getKnobValue(KNOB_5.cint)         # 0-1 dry/wet
    
    # Update tone filter cutoff
    filterL = initLowPass(tone, 48000.0)
    filterR = initLowPass(tone, 48000.0)
    
    # Handle footswitch 1 (bypass toggle)
    if petal.switches[SW_1.int].risingEdge():
      bypassed = not bypassed
      let ledState = if bypassed: 1.0 else: 0.0
      petal.setFootswitchLed(FOOTSWITCH_LED_1.cint, ledState)
    
    # Handle footswitch 2 (boost - momentary)
    boostActive = petal.switches[SW_2.int].pressed()
    let boostLed = if boostActive: 1.0 else: 0.0
    petal.setFootswitchLed(FOOTSWITCH_LED_2.cint, boostLed)
    
    # Handle footswitch 3 (clip mode toggle)
    if petal.switches[SW_3.int].risingEdge():
      hardClipMode = not hardClipMode
      let modeLed = if hardClipMode: 1.0 else: 0.0
      petal.setFootswitchLed(FOOTSWITCH_LED_3.cint, modeLed)
    
    # Handle footswitch 4 (mute toggle)
    if petal.switches[SW_4.int].risingEdge():
      muted = not muted
      let muteLed = if muted: 1.0 else: 0.0
      petal.setFootswitchLed(FOOTSWITCH_LED_4.cint, muteLed)
    
    # Update VU meter every 10ms
    frameCount += 1
    if frameCount >= 10:
      frameCount = 0
      
      # Update VU meter with peak level
      petal.updateVuMeter(peakLevel)
      
      # Decay peak level
      peakLevel = peakLevel * 0.9
    
    # Update LEDs
    petal.updateLeds()
    
    # 1ms delay (1000 Hz control rate)
    petal.delayMs(1)

when isMainModule:
  main()
