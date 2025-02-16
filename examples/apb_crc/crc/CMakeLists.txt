cmake_minimum_required(VERSION 3.25)
project(crc NONE)

add_ip(crc
    LIBRARY bitvis_crc
)

ip_sources(bitvis_crc::crc VHDL
    crc_core.vhd
    crc.vhd
    )

ip_sources(bitvis_crc::crc SYSTEMRDL
    crc_regs.rdl
    )

desyrdl(${IP} 
    INTF ibus
    TOP_ADDRMAP crc_regs)
