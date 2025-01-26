include(${CMAKE_CURRENT_LIST_DIR}/CPM.cmake)

if(NOT SOCMAKE_VERSION)
    CPMAddPackage(
        NAME SoCMake  
        GIT_TAG develop
        GIT_REPOSITORY "https://github.com/HEP-SoC/SoCMake.git"
        )
endif()

