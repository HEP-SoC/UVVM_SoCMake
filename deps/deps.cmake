include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

if(NOT SOCMAKE_VERSION)
    CPMAddPackage(
        NAME SoCMake  
        GIT_TAG b9f4847c
        GIT_REPOSITORY "https://github.com/HEP-SoC/SoCMake.git"
        )
endif()

