# Copyright 2019 Peter Dimov
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt

include(BoostMessage)

if(NOT BOOST_ENABLE_CMAKE)
  message(FATAL_ERROR
    "CMake support in Boost is experimental and part of an ongoing "
    "development effort. It's not ready for use yet. Please use b2 "
    "(Boost.Build) to build and install Boost.")
endif()

set(BOOST_INCLUDE_LIBRARIES "" CACHE STRING "List of libraries to build (default: all but excluded)")
set(BOOST_EXCLUDE_LIBRARIES beast;callable_traits;compute;gil;hana;hof;safe_numerics;serialization;yap CACHE STRING "List of libraries to exclude")

if(CMAKE_SOURCE_DIR STREQUAL Boost_SOURCE_DIR)

  include(CTest)
  add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIG>)

endif()

if(BOOST_INCLUDE_LIBRARIES)

  foreach(__boost_lib IN LISTS BOOST_INCLUDE_LIBRARIES)

    boost_message(VERBOSE "Adding library ${__boost_lib}")
    add_subdirectory("${BOOST_SUPERPROJECT_SOURCE_DIR}/libs/${__boost_lib}" "${CMAKE_CURRENT_BINARY_DIR}/boostorg/${__boost_lib}")

  endforeach()

else()

  file(GLOB __boost_libraries RELATIVE "${BOOST_SUPERPROJECT_SOURCE_DIR}/libs" "${BOOST_SUPERPROJECT_SOURCE_DIR}/libs/*/CMakeLists.txt" "${BOOST_SUPERPROJECT_SOURCE_DIR}/libs/numeric/*/CMakeLists.txt")

  foreach(__boost_lib_cml IN LISTS __boost_libraries)

    get_filename_component(__boost_lib "${__boost_lib_cml}" DIRECTORY)

    if(__boost_lib IN_LIST BOOST_EXCLUDE_LIBRARIES)

      boost_message(VERBOSE "Ignoring excluded library ${__boost_lib}")

    else()

      boost_message(VERBOSE "Adding library ${__boost_lib}")
      add_subdirectory("${BOOST_SUPERPROJECT_SOURCE_DIR}/libs/${__boost_lib}" "${CMAKE_CURRENT_BINARY_DIR}/boostorg/${__boost_lib}")

    endif()

  endforeach()

endif()
