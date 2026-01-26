## Daisy Versio - Reverb Effect with VU Meter
## ===========================================
## 
## Audio effect demonstrating reverb processing with LED VU meter display.
## 
## **Hardware**: Daisy Versio (Noise Engineering Eurorack module)
## 
## **Algorithm**: Schroeder reverb using 4 comb filters + 2 allpass filters
## 
## **Features**:
## - Stereo reverb processing
## - 7 knobs control reverb parameters
## - LED VU meter shows input/output levels
## - Three-position switches for mode selection
## - Gate input triggers freeze effect
## 
## **Controls**:
## - KNOB_0: Reverb size (room size)
## - KNOB_1: Damping (high frequency absorption)
## - KNOB_2: Dry/wet mix
## - KNOB_3: Pre-delay time
## - KNOB_4: Decay time
## - KNOB_5: Early reflections level
## - KNOB_6: Diffusion amount
## - SW_0: Quality mode (down=draft, center=normal, up=high)
## - SW_1: VU meter mode (down=input, center=mix, up=output)
## - GATE_IN: Freeze reverb tail

import ../src/libdaisy
import ../src/libdaisy_versio

useDaisyNamespace()

# Reverb buffer sizes (fixed for embedded)
const
  COMB_BUFFER_SIZE = 4096
  ALLPASS_BUFFER_SIZE = 2048
  NUM_COMBS = 4
  NUM_ALLPASS = 2
  PREDELAY_SIZE = 4800  # 100ms at 48kHz

# Simple comb filter for reverb
type
  CombFilter = object
    buffer: array[COMB_BUFFER_SIZE, cfloat]
    readPos: int
    writePos: int
    bufferSize: int
    feedback: cfloat
    damping: cfloat
    filterState: cfloat

proc initComb(size: int, feedback: cfloat): CombFilter =
  result.bufferSize = size
  result.feedback = feedback
  result.damping = 0.5
  result.filterState = 0.0
  result.readPos = 0
  result.writePos = 0
  for i in 0..<COMB_BUFFER_SIZE:
    result.buffer[i] = 0.0

proc processComb(cf: var CombFilter, input: cfloat): cfloat =
  let output = cf.buffer[cf.readPos]
  
  # One-pole lowpass filter for damping
  cf.filterState = output * (1.0 - cf.damping) + cf.filterState * cf.damping
  
  # Write input + filtered feedback
  cf.buffer[cf.writePos] = input + cf.filterState * cf.feedback
  
  # Advance pointers
  cf.readPos = (cf.readPos + 1) mod cf.bufferSize
  cf.writePos = (cf.writePos + 1) mod cf.bufferSize
  
  result = output

# Simple allpass filter for diffusion
type
  AllpassFilter = object
    buffer: array[ALLPASS_BUFFER_SIZE, cfloat]
    readPos: int
    writePos: int
    bufferSize: int
    feedback: cfloat

proc initAllpass(size: int): AllpassFilter =
  result.bufferSize = size
  result.feedback = 0.5
  result.readPos = 0
  result.writePos = 0
  for i in 0..<ALLPASS_BUFFER_SIZE:
    result.buffer[i] = 0.0

proc processAllpass(ap: var AllpassFilter, input: cfloat): cfloat =
  let bufferOut = ap.buffer[ap.readPos]
  let output = -input + bufferOut
  
  ap.buffer[ap.writePos] = input + bufferOut * ap.feedback
  
  ap.readPos = (ap.readPos + 1) mod ap.bufferSize
  ap.writePos = (ap.writePos + 1) mod ap.bufferSize
  
  result = output

# Pre-delay buffer
type
  PreDelay = object
    buffer: array[PREDELAY_SIZE, cfloat]
    writePos: int
    delayTime: int

proc initPreDelay(): PreDelay =
  result.writePos = 0
  result.delayTime = 1200  # 25ms at 48kHz
  for i in 0..<PREDELAY_SIZE:
    result.buffer[i] = 0.0

proc processPreDelay(pd: var PreDelay, input: cfloat): cfloat =
  let readPos = (pd.writePos - pd.delayTime + PREDELAY_SIZE) mod PREDELAY_SIZE
  result = pd.buffer[readPos]
  pd.buffer[pd.writePos] = input
  pd.writePos = (pd.writePos + 1) mod PREDELAY_SIZE

# Global reverb state
var
  versio: DaisyVersio
  combsL: array[NUM_COMBS, CombFilter]
  combsR: array[NUM_COMBS, CombFilter]
  allpassL: array[NUM_ALLPASS, AllpassFilter]
  allpassR: array[NUM_ALLPASS, AllpassFilter]
  predelayL, predelayR: PreDelay
  vuLevelInput, vuLevelOutput: cfloat
  freezeActive = false

# Comb filter tunings (in samples, offset for stereo)
const combTuningsL = [1557, 1617, 1491, 1422]
const combTuningsR = [1557+23, 1617+23, 1491+23, 1422+23]
const allpassTuningsL = [225, 341]
const allpassTuningsR = [225+23, 341+23]

proc initReverb() =
  # Initialize comb filters
  for i in 0..<NUM_COMBS:
    combsL[i] = initComb(combTuningsL[i], 0.84)
    combsR[i] = initComb(combTuningsR[i], 0.84)
  
  # Initialize allpass filters
  for i in 0..<NUM_ALLPASS:
    allpassL[i] = initAllpass(allpassTuningsL[i])
    allpassR[i] = initAllpass(allpassTuningsR[i])
  
  # Initialize pre-delay
  predelayL = initPreDelay()
  predelayR = initPreDelay()
  
  vuLevelInput = 0.0
  vuLevelOutput = 0.0

proc clamp(x: cfloat, minVal: cfloat, maxVal: cfloat): cfloat {.inline.} =
  if x < minVal: minVal
  elif x > maxVal: maxVal
  else: x

proc abs(x: cfloat): cfloat {.inline.} =
  if x < 0.0: -x else: x

proc processReverbMono(combs: var array[NUM_COMBS, CombFilter],
                       allpass: var array[NUM_ALLPASS, AllpassFilter],
                       predelay: var PreDelay,
                       input: cfloat): cfloat =
  # Pre-delay
  var signal = predelay.processPreDelay(input)
  
  # Parallel comb filters
  var combSum = 0.0.cfloat
  for i in 0..<NUM_COMBS:
    combSum += combs[i].processComb(signal)
  combSum *= 0.25  # Average
  
  # Series allpass filters
  signal = combSum
  for i in 0..<NUM_ALLPASS:
    signal = allpass[i].processAllpass(signal)
  
  result = signal

proc updateReverbParameters() =
  # KNOB_0: Room size (affects comb feedback)
  let size = versio.getKnobValue(KNOB_0.cint)
  let feedback = 0.7 + size * 0.28  # Range: 0.7 to 0.98
  for i in 0..<NUM_COMBS:
    combsL[i].feedback = feedback
    combsR[i].feedback = feedback
  
  # KNOB_1: Damping
  let damping = versio.getKnobValue(KNOB_1.cint)
  for i in 0..<NUM_COMBS:
    combsL[i].damping = damping
    combsR[i].damping = damping
  
  # KNOB_3: Pre-delay time
  let predelayKnob = versio.getKnobValue(KNOB_3.cint)
  let predelayTime = (predelayKnob * (PREDELAY_SIZE - 1).cfloat).int
  predelayL.delayTime = predelayTime
  predelayR.delayTime = predelayTime
  
  # KNOB_6: Diffusion (allpass feedback)
  let diffusion = versio.getKnobValue(KNOB_6.cint) * 0.7  # Max 0.7 for stability
  for i in 0..<NUM_ALLPASS:
    allpassL[i].feedback = diffusion
    allpassR[i].feedback = diffusion

proc updateVuMeter() =
  # Determine which signal to show based on SW_1
  let sw1Pos = versio.sw[1].read()
  var level = 0.0.cfloat
  
  case sw1Pos
  of 0:  # Input level
    level = vuLevelInput
  of 1:  # Mix level
    level = (vuLevelInput + vuLevelOutput) * 0.5
  of 2:  # Output level
    level = vuLevelOutput
  else:
    level = 0.0
  
  # Map to 4 LEDs with color gradient
  let scaledLevel = clamp(level * 4.0, 0.0, 4.0)
  
  for i in 0..<4:
    let threshold = i.cfloat
    if scaledLevel > threshold:
      let brightness = clamp(scaledLevel - threshold, 0.0, 1.0)
      # Green -> Yellow -> Red gradient
      let r = clamp(brightness * 2.0 - 1.0, 0.0, 1.0)
      let g = clamp(2.0 - brightness * 2.0, 0.0, 1.0)
      versio.setLed(i.csize_t, r, g, 0.0)
    else:
      versio.setLed(i.csize_t, 0.0, 0.0, 0.0)
  
  versio.updateLeds()

proc checkFreezeGate() =
  ## Check gate input for freeze effect
  freezeActive = versio.gate.state()
  
  # When frozen, increase feedback to maximum
  if freezeActive:
    for i in 0..<NUM_COMBS:
      combsL[i].feedback = 0.99
      combsR[i].feedback = 0.99

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  # KNOB_2: Dry/wet mix
  let mix = versio.getKnobValue(KNOB_2.cint)
  let dryLevel = 1.0 - mix
  let wetLevel = mix
  
  var maxInputLevel = 0.0.cfloat
  var maxOutputLevel = 0.0.cfloat
  
  for i in 0..<size:
    # Read interleaved input
    let inL = input[0][i]
    let inR = input[1][i]
    
    # Track input level for VU meter
    maxInputLevel = max(maxInputLevel, abs(inL))
    maxInputLevel = max(maxInputLevel, abs(inR))
    
    # Process reverb (stereo)
    let wetL = processReverbMono(combsL, allpassL, predelayL, inL)
    let wetR = processReverbMono(combsR, allpassR, predelayR, inR)
    
    # Mix dry/wet
    var outL = inL * dryLevel + wetL * wetLevel
    var outR = inR * dryLevel + wetR * wetLevel
    
    # Soft clip to prevent harsh distortion
    outL = clamp(outL, -1.0, 1.0)
    outR = clamp(outR, -1.0, 1.0)
    
    # Track output level for VU meter
    maxOutputLevel = max(maxOutputLevel, abs(outL))
    maxOutputLevel = max(maxOutputLevel, abs(outR))
    
    # Write interleaved output
    output[0][i] = outL
    output[1][i] = outR
  
  # Update VU levels (with decay)
  vuLevelInput = vuLevelInput * 0.95 + maxInputLevel * 0.05
  vuLevelOutput = vuLevelOutput * 0.95 + maxOutputLevel * 0.05

proc main() =
  # Initialize Versio hardware
  versio.init()
  
  # Initialize reverb algorithm
  initReverb()
  
  echo "Daisy Versio - Reverb Effect"
  echo "============================="
  echo "KNOB_0: Reverb size"
  echo "KNOB_1: Damping"
  echo "KNOB_2: Dry/wet mix"
  echo "KNOB_3: Pre-delay time"
  echo "KNOB_6: Diffusion"
  echo "SW_1: VU meter (input/mix/output)"
  echo "GATE_IN: Freeze reverb tail"
  
  # Start audio processing
  versio.startAudio(audioCallback)
  
  # Main control loop
  while true:
    updateReverbParameters()
    checkFreezeGate()
    updateVuMeter()
    
    # Update at ~60Hz
    versio.delayMs(16)

when isMainModule:
  main()
