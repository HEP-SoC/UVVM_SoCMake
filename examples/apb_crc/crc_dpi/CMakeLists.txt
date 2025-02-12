cmake_minimum_required(VERSION 3.25)
project(dpi_test CXX C)

include(deps/deps.cmake)

add_library(crc_dpi STATIC
    ./crc_dpi.cpp
    )

target_link_libraries(crc_dpi PRIVATE
    CRCpp
    )
