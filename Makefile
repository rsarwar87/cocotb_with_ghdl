# Default test
DUT ?= maxindexpipeline

# Path to ext deps
EXT := /opt/ext

ifeq (${DUT}, wishbone)
  TOPLEVEL := wishboneslavee
  SIM_ARGS := -gSimulation=true \
    -gAddressWidth=8 \
    -gDataWidth=16
else
  TOPLEVEL := ${DUT}
endif

# Cocotb related
MODULE              := tb_${DUT}
COCOTB_LOG_LEVEL    := DEBUG
CUSTOM_COMPILE_DEPS := results
COCOTB_RESULTS_FILE := results/${MODULE}.xml

# Simulator & RTL related
SIM                  ?= ghdl
TOPLEVEL_LANG        := vhdl
# VHDL_SOURCES_libvhdl := ${EXT}/libvhdl/common/UtilsP.vhd
VHDL_SOURCES         := *.vhd 
VHDL_SOURCES         += /opt/Xilinx/Vivado/2023.2/data/vhdl/src/unimacro/MULT_MACRO.vhd 
SIM_BUILD            := build
SIM_ARGS += -gN=10

ifeq (${SIM}, ghdl)
  COMPILE_ARGS := --std=08 -frelaxed-rules  -fexplicit -fsynopsys 
VHDL_SOURCES_unisim := /opt/Xilinx/Vivado/2022.2/data/vhdl/src/unisims/*.vhd
VHDL_SOURCES_unisim += /opt/Xilinx/Vivado/2022.2/data/vhdl/src/unisims/primitive/*.vhd
VHDL_SOURCES_unimacro :=/opt/Xilinx/Vivado/2022.2/data/vhdl/src/unimacro/MULT_MACRO.vhd
VHDL_SOURCES_unimacro :=/opt/Xilinx/Vivado/2022.2/data/vhdl/src/unimacro/*.vhd
  SIM_ARGS             += \
    --wave=results/${MODULE}.ghw \
    --psl-report=results/${MODULE}_psl.json \
    --vpi-trace=results/${MODULE}_vpi.log
else
  EXTRA_ARGS := --std=08
  VHDL_LIB_ORDER := libvhdl
endif


include $(shell cocotb-config --makefiles)/Makefile.sim


results:
	mkdir -p results


.PHONY: clean
clean::
	rm -rf *.o __pycache__ MaxIndexPipeline wishboneslavee aes results $(SIM_BUILD)
