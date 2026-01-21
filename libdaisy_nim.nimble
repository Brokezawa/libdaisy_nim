# Package

version       = "0.3.0"
author        = "libDaisy Nim Wrapper Contributors"
description   = "Nim bindings for libDaisy - Hardware Abstraction Library for the Daisy Audio Platform"
license       = "MIT"
srcDir        = "."
skipDirs      = @["examples", "examples_nim", "tests", "docs", "Drivers", "Middlewares", "core", "cmake", "ci", "resources"]
skipFiles     = @[]

# Dependencies

requires "nim >= 2.0.0"

# Note: This package provides Nim bindings only.
# You must have libDaisy compiled and available for your target platform.
# For cross-compilation to ARM Cortex-M7, additional setup is required.

task examples, "Build Nim examples":
  echo "Note: Examples require cross-compilation setup for ARM Cortex-M7"
  echo "Please configure your toolchain and build system accordingly"
