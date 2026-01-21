# Makefile template for building Nim programs with libDaisy
# 
# Usage:
#   make              # Build the project
#   make clean        # Clean build artifacts
#   make program-dfu  # Flash to Daisy Seed via DFU
#
# Set your Nim source file here
TARGET = system_info
NIM_SRC = $(TARGET).nim

# Build directory
BUILD_DIR = build

# Paths (adjust these to your setup)
LIBDAISY_DIR = ../libDaisy
SYSTEM_FILES_DIR = $(LIBDAISY_DIR)/core

# Toolchain
NIM = nim
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
LD = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size
DFU_UTIL = dfu-util

# MCU flags
ARCH_FLAGS = -mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard

# Defines
DEFINES = -DSTM32H750xx -DCORE_CM7 -DARM_MATH_CM7

# Include paths
INCLUDES = \
	-I$(LIBDAISY_DIR)/src \
	-I$(LIBDAISY_DIR)/src/sys \
	-I$(LIBDAISY_DIR)/src/usbd \
	-I$(LIBDAISY_DIR)/src/usbh \
	-I$(LIBDAISY_DIR)/core \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS_5/CMSIS/Core/Include \
	-I$(LIBDAISY_DIR)/Drivers/CMSIS-Device/ST/STM32H7xx/Include \
	-I$(LIBDAISY_DIR)/Drivers/STM32H7xx_HAL_Driver/Inc \
	-I$(LIBDAISY_DIR)/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Host_Library/Core/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/ST/STM32_USB_Device_Library/Core/Inc \
	-I$(LIBDAISY_DIR)/Middlewares/Third_Party/FatFs/src
# C/C++ flags
CFLAGS = $(ARCH_FLAGS) $(DEFINES) $(INCLUDES) -Os -Wall -fdata-sections -ffunction-sections
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti

# Linker flags
LDFLAGS = $(ARCH_FLAGS) \
	-L$(LIBDAISY_DIR)/build \
	-T$(SYSTEM_FILES_DIR)/STM32H750IB_flash.lds \
	-Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
	-Wl,--gc-sections \
	-Wl,--print-memory-usage \
	-ldaisy

# Nim compile flags
NIMFLAGS = \
	--clearNimblePath \
	--nimblePath:off \
	--skipUserCfg \
	--skipParentCfg \
	--cpu:arm \
	--os:standalone \
	--mm:arc \
	--opt:size \
	--threads:off \
	--exceptions:goto \
	--panics:on \
	--define:useMalloc \
	--define:noSignalHandler \
	--cc:gcc \
	--gcc.exe:$(CC) \
	--gcc.linkerexe:$(LD) \
	--gcc.cpp.exe:$(CXX) \
	--gcc.cpp.linkerexe:$(LD) \
	--nimcache:$(BUILD_DIR)/.nimcache

# Additional Nim pass flags
NIMFLAGS += $(foreach flag,$(CFLAGS),--passC:"$(flag)")
NIMFLAGS += $(foreach flag,$(LDFLAGS),--passL:"$(flag)")

# Build target
all: $(BUILD_DIR)/$(TARGET).bin

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile Nim to C/C++
$(BUILD_DIR)/$(TARGET).elf: $(NIM_SRC) | $(BUILD_DIR)
	@echo "Building Nim project: $(NIM_SRC)"
	$(NIM) cpp $(NIMFLAGS) --nimMainPrefix:nim_ -o:$@ $<
	@echo "Binary size:"
	@$(SIZE) $@

# Create binary file for flashing
$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# Create hex file (alternative format)
$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

# Disassembly for debugging
$(BUILD_DIR)/$(TARGET).asm: $(BUILD_DIR)/$(TARGET).elf
	$(OBJDUMP) -d $< > $@

# Program via DFU
program-dfu: $(BUILD_DIR)/$(TARGET).bin
	@echo "Flashing $(BUILD_DIR)/$(TARGET).bin via DFU..."
	$(DFU_UTIL) -a 0 -s 0x08000000:leave -D $<

# Program via STLink (if available)
program-stlink: $(BUILD_DIR)/$(TARGET).bin
	st-flash write $< 0x8000000

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean program-dfu program-stlink
