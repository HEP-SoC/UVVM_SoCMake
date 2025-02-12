
cmake_minimum_required(VERSION 3.25)
project(crc NONE)


add_ip(crc
    LIBRARY bitvis_crc
)

ip_sources(bitvis_crc::crc VHDL
    ./crc_pif_pkg.vhd
    ./crc_pif.vhd
    ./crc_core.vhd
    ./crc.vhd
    )
