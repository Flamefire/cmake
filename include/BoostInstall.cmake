# Copyright 2019 Peter Dimov
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt

if(NOT CMAKE_VERSION VERSION_LESS 3.10)
  include_guard()
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

function(boost_install LIB)

    set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${LIB}-${PROJECT_VERSION}")

    install(TARGETS ${LIB} EXPORT ${LIB}-targets)
    install(EXPORT ${LIB}-targets DESTINATION "${CONFIG_INSTALL_DIR}" NAMESPACE Boost:: FILE ${LIB}-targets.cmake)

    install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

    get_target_property(INTERFACE_LINK_LIBRARIES ${LIB} INTERFACE_LINK_LIBRARIES)
    get_target_property(TYPE ${LIB} TYPE)

    set(CONFIG_FILE_NAME "${CMAKE_BINARY_DIR}/${LIB}-config.cmake")
    set(CONFIG_FILE_CONTENTS "# Generated by BoostInstall.cmake for ${LIB}-${PROJECT_VERSION}\n\n")

    if(INTERFACE_LINK_LIBRARIES)

        string(APPEND CONFIG_FILE_CONTENTS "include(CMakeFindDependencyMacro)\n\n")

        foreach(dep IN LISTS INTERFACE_LINK_LIBRARIES)

            if(${dep} MATCHES "^Boost::")

                string(REGEX REPLACE "^Boost::(.*)" "\\1" name "${dep}")
                string(APPEND CONFIG_FILE_CONTENTS "find_dependency(boost_${name} ${PROJECT_VERSION} EXACT)\n")

            endif()

        endforeach()

        string(APPEND CONFIG_FILE_CONTENTS "\n")

    endif()

    string(APPEND CONFIG_FILE_CONTENTS "include(\"\${CMAKE_CURRENT_LIST_DIR}/${LIB}-targets.cmake\")\n")
    
    file(WRITE "${CONFIG_FILE_NAME}" "${CONFIG_FILE_CONTENTS}")
    install(FILES "${CONFIG_FILE_NAME}" DESTINATION "${CONFIG_INSTALL_DIR}")

    set(CONFIG_VERSION_FILE_NAME "${PROJECT_BINARY_DIR}/${LIB}-config-version.cmake")

    if(TYPE STREQUAL "INTERFACE_LIBRARY")

        # Header-only libraries are arcitecture-independent

        if(NOT CMAKE_VERSION VERSION_LESS 3.14)

            write_basic_package_version_file("${CONFIG_VERSION_FILE_NAME}" COMPATIBILITY AnyNewerVersion ARCH_INDEPENDENT)

        else()

            set(OLD_CMAKE_SIZEOF_VOID_P ${CMAKE_SIZEOF_VOID_P})
            set(CMAKE_SIZEOF_VOID_P "")

            write_basic_package_version_file("${CONFIG_VERSION_FILE_NAME}" COMPATIBILITY AnyNewerVersion)

            set(CMAKE_SIZEOF_VOID_P ${OLD_CMAKE_SIZEOF_VOID_P})

        endif()

    else()

        write_basic_package_version_file("${CONFIG_VERSION_FILE_NAME}" COMPATIBILITY AnyNewerVersion)

    endif()

    install(FILES "${CONFIG_VERSION_FILE_NAME}" DESTINATION "${CONFIG_INSTALL_DIR}")

endfunction()
