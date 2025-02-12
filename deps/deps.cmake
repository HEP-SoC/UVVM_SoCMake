include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

if(NOT SOCMAKE_VERSION)
    CPMAddPackage(
        NAME SoCMake  
        GIT_TAG 4ace065e
        GIT_REPOSITORY "https://github.com/HEP-SoC/SoCMake.git"
        )
endif()

