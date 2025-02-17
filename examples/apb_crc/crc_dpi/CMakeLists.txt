cmake_minimum_required(VERSION 3.25)
project(dpi_test CXX C)

CPMAddPackage(
    NAME CRCpp
    GIT_TAG release-1.2.0.0
    GIT_REPOSITORY "https://github.com/d-bahr/CRCpp.git"
    OPTIONS "BUILD_TEST OFF"
    )

add_library(crc_dpi STATIC
    ./crc_dpi.cpp
    )

target_link_libraries(crc_dpi PRIVATE
    CRCpp
    )
