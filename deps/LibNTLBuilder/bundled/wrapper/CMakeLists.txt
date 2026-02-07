cmake_minimum_required(VERSION 3.10)
project(LibNTL_wrapper CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(JlCxx REQUIRED)
find_package(PkgConfig QUIET)

# Try to find NTL via pkg-config first, then fall back to manual search
if(PkgConfig_FOUND)
    pkg_check_modules(NTL QUIET ntl)
endif()

if(NOT NTL_FOUND)
    # Manual search for NTL
    find_path(NTL_INCLUDE_DIRS
        NAMES NTL/ZZ.h
        PATHS
            ${CMAKE_PREFIX_PATH}/include
            /usr/include
            /usr/local/include
            /opt/homebrew/include
    )
    find_library(NTL_LIBRARIES
        NAMES ntl
        PATHS
            ${CMAKE_PREFIX_PATH}/lib
            /usr/lib
            /usr/local/lib
            /opt/homebrew/lib
    )
    if(NTL_INCLUDE_DIRS AND NTL_LIBRARIES)
        set(NTL_FOUND TRUE)
    endif()
endif()

if(NOT NTL_FOUND)
    message(FATAL_ERROR "NTL library not found")
endif()

message(STATUS "NTL include: ${NTL_INCLUDE_DIRS}")
message(STATUS "NTL library: ${NTL_LIBRARIES}")

# Create the shared library
add_library(libntl_julia SHARED
    libntl_julia.cpp
)

# Link against CxxWrap and NTL
target_link_libraries(libntl_julia
    PRIVATE JlCxx::cxxwrap_julia
    PRIVATE ${NTL_LIBRARIES}
)

# Include NTL headers
target_include_directories(libntl_julia
    PRIVATE ${NTL_INCLUDE_DIRS}
)

# Enable NTL exceptions
target_compile_definitions(libntl_julia
    PRIVATE NTL_EXCEPTIONS=on
)

# Set output name without 'lib' prefix on Unix (already has 'lib' in name)
set_target_properties(libntl_julia PROPERTIES
    PREFIX ""
    OUTPUT_NAME "libntl_julia"
)

# Install the library
install(TARGETS libntl_julia
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
