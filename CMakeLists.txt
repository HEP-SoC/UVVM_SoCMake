cmake_minimum_required(VERSION 3.25)
project(uvvm NONE)

include(${CMAKE_CURRENT_LIST_DIR}/deps/deps.cmake)

option_boolean(UVVM_BUILD_TESTING "Include test targets" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_ALL_LIBS "Include all libraries" OFF ADVANCED)
option_string(UVVM_VERSION "Which UVVM version to fetch" "v2_2024.10.23" ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_AVALON_ST "Include BITVIS VIP AVALON STREAM" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_AVALON_MM "Include BITVIS VIP AVALON MEMORY MAPPED" OFF ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_AXILITE "Include BITVIS VIP AXILITE" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_AXISTREAM "Include BITVIS VIP AXISTREAM" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_AXI "Include BITVIS VIP AXI" OFF ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_WISHBONE "Include BITVIS VIP WISHBONE" OFF ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_CLOCK_GENERATOR "Include BITVIS VIP CLOCK_GENERATOR" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_ERROR_INJECTION "Include BITVIS VIP ERROR_INJECTION" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_SPEC_COV "Include BITVIS VIP SPEC COV" OFF ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_GMII "Include BITVIS VIP GMII" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_RGMII "Include BITVIS VIP RGMII" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_GPIO "Include BITVIS VIP GPIO" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_HVVC_TO_VVC_BRIDGE "Include BITVIS VIP HVVC TO VVC BRIDGE" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_ETHERNET "Include BITVIS VIP ETHERNET" OFF ADVANCED)

option_boolean(UVVM_INCLUDE_BITVIS_VIP_I2C "Include BITVIS VIP I2C" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_SBI "Include BITVIS VIP SBI" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_SPI "Include BITVIS VIP SPI" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_UART "Include BITVIS VIP UART" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_UART "Include BITVIS UART" OFF ADVANCED)
option_boolean(UVVM_INCLUDE_BITVIS_VIP_IRQC "Include BITVIS VIP IRQC" OFF ADVANCED)

if(UVVM_INCLUDE_BITVIS_VIP_ETHERNET)
    set(UVVM_INCLUDE_BITVIS_VIP_HVVC_TO_VVC_BRIDGE ON)
endif()
if(UVVM_INCLUDE_BITVIS_VIP_HVVC_TO_VVC_BRIDGE)
    set(UVVM_INCLUDE_BITVIS_VIP_SBI ON)
    set(UVVM_INCLUDE_BITVIS_VIP_GMII ON)
endif()

###############################################
############ Fetch UVVM repo ##################
###############################################
CPMAddPackage(NAME uvvm
    GIT_REPOSITORY https://github.com/UVVM/UVVM.git
    GIT_TAG ${UVVM_VERSION}
    )


###############################################
############ uvvm_util ########################
###############################################

add_ip(uvvm::uvvm_util::util::0.0.1
    )

ip_sources(${IP} VHDL
    ${uvvm_SOURCE_DIR}/uvvm_util/src/types_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/adaptations_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/string_methods_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/protected_types_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/global_signals_and_shared_variables_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/hierarchy_linked_list_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/alert_hierarchy_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/license_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/methods_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/bfm_common_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/generic_queue_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/data_queue_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/data_fifo_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/data_stack_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/rand_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/func_cov_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_util/src/uvvm_util_context.vhd
    )

if(UVVM_BUILD_TESTING)
    modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
endif()

###############################################
############ uvvm_vvc_framework ###############
###############################################

add_ip(uvvm::uvvm_vvc_framework::uvvm_vvc_framework::0.0.1)


ip_sources(${IP} VHDL
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_protected_types_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_vvc_framework_support_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_generic_queue_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_data_queue_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_data_fifo_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_data_stack_pkg.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_uvvm_engine.vhd
    ${uvvm_SOURCE_DIR}/uvvm_vvc_framework/src/ti_vvc_framework_context.vhd
    )

ip_link(${IP}
    uvvm::uvvm_util::util
    )

if(UVVM_BUILD_TESTING)
    modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
endif()

###############################################
############ bitvis_vip_scoreboard ############
###############################################

add_ip(uvvm::bitvis_vip_scoreboard::vip::0.0.1)

ip_sources(${IP} VHDL
    ${uvvm_SOURCE_DIR}/bitvis_vip_scoreboard/src/generic_sb_support_pkg.vhd
    ${uvvm_SOURCE_DIR}/bitvis_vip_scoreboard/src/generic_sb_pkg.vhd
    ${uvvm_SOURCE_DIR}/bitvis_vip_scoreboard/src/predefined_sb.vhd
    )

ip_link(${IP}
    uvvm::uvvm_util::util
    # uvvm::uvvm_vvc_framework::uvvm_vvc_framework
    )

if(UVVM_BUILD_TESTING)
    modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
endif()

###############################################
############ bitvis_vip_avalon_st #############
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_AVALON_ST OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_avalon_st::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/avalon_st_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_avalon_st::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/avalon_st_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_st/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_avalon_st::bfm
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_axilite ###############
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_AXILITE OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_axilite::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/axilite_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_axilite::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/axilite_channel_handler_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/axilite_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axilite/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_axilite::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_axstream ##############
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_AXISTREAM OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_axistream::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/axistream_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_axistream::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/axistream_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axistream/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_axistream::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
######### bitvis_vip_clock_generator ##########
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_CLOCK_GENERATOR OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_clock_generator::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/src/clock_generator_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_clock_generator/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
######### bitvis_vip_error_injection ##########
###############################################


if(UVVM_INCLUDE_BITVIS_VIP_ERROR_INJECTION OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_error_injection::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_error_injection/src/error_injection_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_error_injection/src/error_injection_slv.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_error_injection/src/error_injection_sl.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_error_injection::ei_demo_tb::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_error_injection/tb/ei_demo_tb.vhd
        )

    ip_link(${IP}
        uvvm::bitvis_vip_error_injection::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
######### bitvis_vip_gmii #####################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_GMII OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_gmii::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/gmii_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_gmii::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/gmii_tx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/gmii_rx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/gmii_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gmii/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_gmii::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
######### bitvis_vip_gpio #####################
###############################################


if(UVVM_INCLUDE_BITVIS_VIP_GPIO OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_gpio::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/gpio_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_gpio::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/gpio_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_gpio/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_gpio::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_i2c ###################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_I2C OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_i2c::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/i2c_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_i2c::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/i2c_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_i2c/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_i2c::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_rgmii #################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_RGMII OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_rgmii::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/rgmii_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_rgmii::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/rgmii_bfm_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/rgmii_tx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/rgmii_rx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/rgmii_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_rgmii/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_rgmii::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_sbi ###################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_SBI OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_sbi::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/sbi_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_sbi::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/sbi_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_sbi/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_sbi::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_spi ###################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_SPI OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_spi::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/spi_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_spi::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/spi_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spi/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_spi::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_uart ##################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_UART OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_uart::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/uart_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_uart::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/monitor_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/uart_rx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/uart_tx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/uart_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/uart_monitor.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_uart/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_uart::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
###### bitvis_vip_hvvc_to_vvc_bridge ##########
############################################### # TODO not working yet

if(UVVM_INCLUDE_BITVIS_VIP_HVVC_TO_VVC_BRIDGE OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_hvvc_to_vvc_bridge::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_hvvc_to_vvc_bridge/src/support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_hvvc_to_vvc_bridge/src/hvvc_to_vvc_bridge.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_hvvc_to_vvc_bridge/src/hvvc_to_vvc_bridge_gmii.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_hvvc_to_vvc_bridge/src/hvvc_to_vvc_bridge_sbi.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_gmii::bfm
        # uvvm::bitvis_vip_scoreboard::vip
        # uvvm::bitvis_vip_sbi::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
########## bitvis_vip_ethernet ################
############################################### # TODO not working yet

if(UVVM_INCLUDE_BITVIS_VIP_ETHERNET OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_ethernet::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/ethernet_rx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/ethernet_tx_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/ethernet_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_ethernet/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_gmii::bfm
        uvvm::bitvis_vip_scoreboard::vip
        uvvm::bitvis_vip_hvvc_to_vvc_bridge::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
########## bitvis_vip_axi #####################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_AXI OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_axi::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/axi_bfm_pkg.vhd
        )

    add_ip(uvvm::bitvis_vip_axi::vip::0.0.1)

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/axi_read_data_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/axi_channel_handler_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/axi_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_axi/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_axi::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
########## bitvis_vip_spec_cov ################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_SPEC_COV OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_spec_cov::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_spec_cov/src/local_adaptations_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spec_cov/src/csv_file_reader_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_spec_cov/src/spec_cov_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )


    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
########## bitvis_vip_wishbone ################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_WISHBONE OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_wishbone::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/wishbone_bfm_pkg.vhd
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_wishbone::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/wishbone_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_wishbone/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_wishbone::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
########## bitvis_vip_irqc ################
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_IRQC OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_irqc::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_irqc/src/irqc_pif_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_irqc/src/irqc_pif.vhd
        ${uvvm_SOURCE_DIR}/bitvis_irqc/src/irqc_core.vhd
        ${uvvm_SOURCE_DIR}/bitvis_irqc/src/irqc.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    if(UVVM_BUILD_TESTING)
        add_ip(uvvm::bitvis_irqc::irqc_demo_tb::0.0.1)

        ip_sources(${IP} VHDL
            ${uvvm_SOURCE_DIR}/bitvis_irqc/tb/irqc_demo_tb.vhd
            )

        ip_link(${IP}
            uvvm::bitvis_irqc::vip
            uvvm::bitvis_vip_sbi::vip
            )

        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236)
    endif()
endif()

###############################################
############ bitvis_uart ######################
###############################################

if(UVVM_INCLUDE_BITVIS_UART OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_uart::uart::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_uart/src/uart_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_uart/src/uart_pif_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_uart/src/uart_pif.vhd
        ${uvvm_SOURCE_DIR}/bitvis_uart/src/uart_core.vhd
        ${uvvm_SOURCE_DIR}/bitvis_uart/src/uart.vhd
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

###############################################
############ bitvis_vip_avalon_mm #############
###############################################

if(UVVM_INCLUDE_BITVIS_VIP_AVALON_MM OR UVVM_INCLUDE_ALL_LIBS)
    add_ip(uvvm::bitvis_vip_avalon_mm::bfm::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/avalon_mm_bfm_pkg.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()

    add_ip(uvvm::bitvis_vip_avalon_mm::vip::0.0.1)

    ip_sources(${IP} VHDL
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/transaction_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/vvc_cmd_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/../uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/../uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/vvc_sb_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/vvc_methods_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/../uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/avalon_mm_vvc.vhd
        ${uvvm_SOURCE_DIR}/bitvis_vip_avalon_mm/src/vvc_context.vhd
        )

    ip_link(${IP}
        uvvm::uvvm_util::util
        uvvm::uvvm_vvc_framework::uvvm_vvc_framework
        uvvm::bitvis_vip_avalon_mm::bfm
        uvvm::bitvis_vip_scoreboard::vip
        )

    if(UVVM_BUILD_TESTING)
        modelsim(${IP} VCOM_ARGS -2008 -suppress 1346,1236 NO_RUN_TARGET)
    endif()
endif()

# help()

