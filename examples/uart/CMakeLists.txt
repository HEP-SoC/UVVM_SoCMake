cmake_minimum_required(VERSION 3.25)
project(uart_vvc_demo_tb NONE)

###############################################
############ Package management ###############
###############################################

# Include CPM package manager, otherwise you can use built in FetchContent
include("../../deps/CPM.cmake")

# Fetch SoCMake
CPMAddPackage(
    NAME SoCMake  
    GIT_TAG 4ace065e
    GIT_REPOSITORY "https://github.com/HEP-SoC/SoCMake.git"
    )

set(CPM_uvvm_socmake_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/../../")
CPMAddPackage(NAME uvvm_socmake
    GIT_REPOSITORY https://github.com/HEP-SoC/UVVM_SoCMake.git
    GIT_TAG master
    OPTIONS 
        "UVVM_VERSION v2_2024.10.23"
        # Decide which libraries to include from UVVM
        "UVVM_INCLUDE_BITVIS_VIP_SBI ON"
        "UVVM_INCLUDE_BITVIS_VIP_UART ON"
        "UVVM_INCLUDE_BITVIS_UART ON"
        "UVVM_INCLUDE_BITVIS_VIP_CLOCK_GENERATOR ON"
    )


###############################################
############ CLI options ######################
###############################################

# Pass these options with -D<option>=<value> with cmake call, or through cmake-gui
option_enum(SIMULATOR "Which simulator to use" "ghdl;questa;modelsim;vivado_sim;all" "ghdl")
if(SIMULATOR STREQUAL "all")
    set(ALL_SIMS TRUE)
endif()

# Add IP for the uart demo project
add_ip(${PROJECT_NAME}
    LIBRARY bitvis_uart)

# Include demo testbench sources
ip_sources(${IP} VHDL
    ./uart_vvc_demo_th.vhd
    ./uart_vvc_demo_tb.vhd
    )

ip_link(${IP}
    uvvm::bitvis_vip_sbi::vip
    uvvm::bitvis_vip_uart::vip
    uvvm::bitvis_uart::uart
    uvvm::bitvis_vip_clock_generator::vip
)

if(SIMULATOR STREQUAL "questa" OR SIMULATOR STREQUAL "modelsim" OR ALL_SIMS)
    modelsim(${IP} QUIET VHDL_COMPILE_ARGS -2008 -suppress 1346,1236,1246)
endif()

if(SIMULATOR STREQUAL "vivado_sim" OR ALL_SIMS)
    vivado_sim(${IP} 
        XVHDL_ARGS --2008 --relax
        XELAB_ARGS --relax
    )
endif()

if(SIMULATOR STREQUAL "ghdl" OR ALL_SIMS)
    ghdl(${IP}
        STANDARD 08
        VHDL_COMPILE_ARGS -frelaxed-rules -Wno-hide -Wno-shared
        ELABORATE_ARGS    -frelaxed-rules
    )
endif()

help()
