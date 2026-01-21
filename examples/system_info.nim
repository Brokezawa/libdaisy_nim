## System Information Example
## 
## This example demonstrates system utilities:
## - UniqueId - Read STM32 unique device identifier
## - CpuLoadMeter - Real-time CPU load monitoring during audio processing
##
## Shows how to identify hardware, monitor performance, and optimize
## audio processing workloads.

import ../src/libdaisy
import ../src/libdaisy_uniqueid
import ../src/libdaisy_cpuload
import ../src/libdaisy_fixedstr

useDaisyNamespace()

var
  daisy: DaisySeed
  cpuMeter: CpuLoadMeter
  sampleRate: float32 = 48000.0
  blockSize: int = 48
  processingLoad: float32 = 0.5  # Simulated workload (0-1)
  ledState: bool = false

proc simulateProcessing(load: float32) =
  ## Simulate CPU-intensive audio processing
  ## load: 0.0 = no work, 1.0 = maximum work
  if load <= 0.0:
    return
  
  # Simulate DSP work with floating point operations
  # (In real code, this would be your actual audio processing)
  let iterations = int(load * 1000.0)
  var dummy: float32 = 0.0
  for i in 0 ..< iterations:
    dummy += float32(i) * 0.001
    dummy = dummy * 0.99

proc audioCallback(input, output: AudioBuffer, size: int) {.cdecl.} =
  ## Audio callback with CPU load measurement
  cpuMeter.onBlockStart()
  
  # Simulate audio processing with configurable workload
  simulateProcessing(processingLoad)
  
  # Simple passthrough
  for i in 0 ..< size:
    output[0][i] = input[0][i]  # Left channel
    output[1][i] = input[1][i]  # Right channel
  
  cpuMeter.onBlockEnd()

proc displayDeviceInfo() =
  ## Display device identification information
  echo "======================================"
  echo "  Device Information"
  echo "======================================"
  echo ""
  
  # Read unique ID
  let uid = getUniqueId()
  echo "STM32 Unique ID (96-bit):"
  echo "  ", uid
  echo ""
  
  # Display as serial number string
  let serialNumber = getUniqueIdString()
  echo "Serial Number: ", serialNumber
  echo ""
  
  # Use for device identification
  var deviceName: FixedStr[64]
  deviceName.init()
  discard deviceName.add("DaisySeed-")
  discard deviceName.add(serialNumber)
  echo "Device Name: ", $deviceName
  echo ""

proc displayAudioConfig() =
  ## Display audio configuration
  echo "======================================"
  echo "  Audio Configuration"
  echo "======================================"
  echo ""
  
  echo "Sample Rate: ", int(sampleRate), " Hz"
  echo "Block Size: ", blockSize, " samples"
  let blockTime = (float32(blockSize) / sampleRate) * 1000.0
  echo "Block Time: ", blockTime, " ms"
  echo "Block Rate: ", int(sampleRate / float32(blockSize)), " Hz"
  echo ""

proc monitorCpuLoad(duration: int) =
  ## Monitor CPU load for specified duration
  echo "======================================"
  echo "  CPU Load Monitoring"
  echo "======================================"
  echo ""
  
  echo "Monitoring CPU load for ", duration, " seconds..."
  echo "Workload level: ", int(processingLoad * 100.0), "%"
  echo ""
  echo "Time | Avg Load | Min Load | Max Load"
  echo "-----+----------+----------+---------"
  
  for i in 1..duration:
    daisy.delay(1000)
    
    let avgLoad = cpuMeter.getAvgCpuLoad()
    let minLoad = cpuMeter.getMinCpuLoad()
    let maxLoad = cpuMeter.getMaxCpuLoad()
    
    # Format output
    var line: FixedStr[64]
    line.init()
    discard line.add(i)
    discard line.add("s   | ")
    discard line.add(int(avgLoad * 100.0))
    discard line.add("%      | ")
    discard line.add(int(minLoad * 100.0))
    discard line.add("%      | ")
    discard line.add(int(maxLoad * 100.0))
    discard line.add("%")
    
    echo $line
    
    # Blink LED at different rates based on load
    if i mod 2 == 0:
      ledState = not ledState
      daisy.setLed(ledState)

proc demonstrateLoadScaling() =
  ## Show CPU load at different workload levels
  echo ""
  echo "======================================"
  echo "  CPU Load Scaling Test"
  echo "======================================"
  echo ""
  
  let testLoads = [0.1'f32, 0.3'f32, 0.5'f32, 0.7'f32, 0.9'f32]
  
  for load in testLoads:
    processingLoad = load
    cpuMeter.reset()
    
    echo "Testing with ", int(load * 100.0), "% workload..."
    
    # Let it stabilize for 2 seconds
    daisy.delay(2000)
    
    let avgLoad = cpuMeter.getAvgCpuLoad()
    let maxLoad = cpuMeter.getMaxCpuLoad()
    
    echo "  Average CPU: ", int(avgLoad * 100.0), "%"
    echo "  Peak CPU: ", int(maxLoad * 100.0), "%"
    
    if avgLoad > 0.95:
      echo "  WARNING: CPU approaching limit!"
    
    echo ""

proc demonstratePerformanceTips() =
  ## Display performance optimization information
  echo "======================================"
  echo "  Performance Tips"
  echo "======================================"
  echo ""
  
  echo "CPU Load Interpretation:"
  echo "  0-50%   : Plenty of headroom"
  echo "  50-70%  : Moderate usage"
  echo "  70-90%  : High usage - optimize if possible"
  echo "  90-100% : Critical - risk of dropouts"
  echo "  >100%   : Audio dropouts occurring!"
  echo ""
  
  echo "Optimization Strategies:"
  echo "  1. Use lookup tables instead of sin/cos/exp"
  echo "  2. Avoid divisions (use multiplication by reciprocal)"
  echo "  3. Use fixed-point instead of float when possible"
  echo "  4. Minimize memory allocations (use stack/static)"
  echo "  5. Unroll critical loops manually if needed"
  echo "  6. Use {.inline.} pragma for small functions"
  echo "  7. Profile with CPU meter to find bottlenecks"
  echo ""

proc demonstrateRealtimeConstraints() =
  ## Show audio realtime constraints
  echo "======================================"
  echo "  Realtime Constraints"
  echo "======================================"
  echo ""
  
  let blockTimeUs = (float32(blockSize) / sampleRate) * 1000000.0
  echo "Available time per audio block: ", int(blockTimeUs), " µs"
  echo ""
  
  echo "At 48 kHz, 48-sample blocks:"
  echo "  Block time: 1000 µs (1 ms)"
  echo "  Block rate: 1000 Hz"
  echo "  Must process 48 samples in < 1ms"
  echo ""
  
  echo "CPU Usage Examples (at 400 MHz):"
  echo "  10% load  = 100 µs per block = 40,000 cycles"
  echo "  50% load  = 500 µs per block = 200,000 cycles"
  echo "  90% load  = 900 µs per block = 360,000 cycles"
  echo ""
  
  echo "Safe operating range: Keep CPU < 80% for stability"
  echo ""

proc main() =
  echo "======================================"
  echo "  libdaisy_nim System Info Demo"
  echo "======================================"
  echo ""
  
  # Initialize hardware
  daisy.init()
  daisy.setBlockSize(blockSize)
  sampleRate = daisy.sampleRate()
  
  # Initialize CPU meter
  cpuMeter.init(sampleRate, blockSize, smoothingFilterCutoffHz = 1.0)
  
  # Display device information
  displayDeviceInfo()
  displayAudioConfig()
  demonstrateRealtimeConstraints()
  demonstratePerformanceTips()
  
  # Start audio processing
  echo "======================================"
  echo "  Starting Audio Processing"
  echo "======================================"
  echo ""
  daisy.startAudio(audioCallback)
  
  # Monitor CPU load
  processingLoad = 0.5  # 50% simulated workload
  monitorCpuLoad(10)
  
  # Test different load levels
  demonstrateLoadScaling()
  
  # Reset to moderate load
  processingLoad = 0.3
  cpuMeter.reset()
  
  echo "======================================"
  echo "  Continuous Monitoring"
  echo "======================================"
  echo ""
  echo "Device: ", getUniqueIdString()
  echo "Workload: ", int(processingLoad * 100.0), "%"
  echo "Press Ctrl+C to stop"
  echo ""
  
  # Continuous monitoring loop
  var loopCount = 0
  while true:
    daisy.delay(5000)  # Update every 5 seconds
    inc(loopCount)
    
    let avgLoad = cpuMeter.getAvgCpuLoad()
    let maxLoad = cpuMeter.getMaxCpuLoad()
    
    var statusLine: FixedStr[64]
    statusLine.init()
    discard statusLine.add("[")
    discard statusLine.add(loopCount * 5)
    discard statusLine.add("s] CPU: ")
    discard statusLine.add(int(avgLoad * 100.0))
    discard statusLine.add("% (peak ")
    discard statusLine.add(int(maxLoad * 100.0))
    discard statusLine.add("%)")
    
    echo $statusLine
    
    # Visual indicator on LED
    ledState = not ledState
    daisy.setLed(ledState)
    
    # Warning if load is high
    if avgLoad > 0.8:
      echo "  WARNING: High CPU usage!"

when isMainModule:
  main()
