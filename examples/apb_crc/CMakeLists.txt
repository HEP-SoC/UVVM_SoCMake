cmake_minimum_required(VERSION 3.25)
project(crc_vvc_demo_tb C)

###############################################
############ Package management ###############
###############################################

# Include CPM package manager, otherwise you can use built in FetchContent
include("../../deps/CPM.cmake")

# Fetch SoCMake
CPMAddPackage(
    NAME SoCMake  
    GIT_TAG f8b7c477
    GIT_REPOSITORY "https://github.com/HEP-SoC/SoCMake.git"
    )

CPMAddPackage(NAME uvvm_socmake
    GIT_REPOSITORY https://github.com/HEP-SoC/UVVM_SoCMake.git
    GIT_TAG master
    OPTIONS 
        "UVVM_VERSION v2_2024.10.23"
        # Decide which libraries to include from UVVM
        "UVVM_INCLUDE_BITVIS_VIP_SBI ON"
        "UVVM_INCLUDE_BITVIS_VIP_CLOCK_GENERATOR ON"
    )

# ###############################################
# ############ CLI options ######################
# ###############################################
#
# Pass these options with -D<option>=<value> with cmake call, or through cmake-gui
# option_enum(SIMULATOR "Which simulator to use" "ghdl;questa;modelsim" "ghdl")


add_subdirectory(crc)
add_subdirectory(crc_dpi)

# # Add IP for the uart demo project
add_ip(${PROJECT_NAME}
    LIBRARY bitvis_crc)
#
# # Include demo testbench sources
ip_sources(${IP} VHDL
    ./crc_vvc_demo_th.vhd
    ./crc_vvc_demo_tb.vhd
    )
#
ip_link(${IP}
    bitvis_crc::crc
    uvvm::bitvis_vip_sbi::vip
    uvvm::bitvis_vip_clock_generator::vip
    crc_dpi
)

ghdl(${IP}
    STANDARD 08
    VHDL_COMPILE_ARGS -frelaxed-rules -Wno-hide -Wno-shared
    ELABORATE_ARGS    -frelaxed-rules
    RUN_ARGS          --wave=trace.ghw
)

help()

