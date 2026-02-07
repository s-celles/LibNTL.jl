#!/usr/bin/env julia
"""
Build script for LibNTL C++ wrapper.

This script compiles the CxxWrap-based wrapper for NTL and creates
a LocalPreferences.toml file to configure the library path.

Prerequisites:
- NTL library installed (libntl-dev on Ubuntu/Debian)
- CMake 3.10+
- C++17 compatible compiler
"""

using Pkg
using CxxWrap

# Directories
const DEPS_DIR = @__DIR__
const WRAPPER_DIR = joinpath(DEPS_DIR, "LibNTLBuilder", "bundled", "wrapper")
const BUILD_DIR = joinpath(DEPS_DIR, "build")
const LIB_DIR = joinpath(DEPS_DIR, "lib")
const PROJECT_DIR = dirname(DEPS_DIR)

function find_jlcxx_prefix()
    # Get the JlCxx CMake directory from CxxWrap
    cxxwrap_prefix = CxxWrap.prefix_path()
    jlcxx_dir = joinpath(cxxwrap_prefix, "lib", "cmake", "JlCxx")
    if !isdir(jlcxx_dir)
        # Try alternative location
        jlcxx_dir = joinpath(cxxwrap_prefix, "share", "cmake", "JlCxx")
    end
    return jlcxx_dir
end

function check_ntl_installed()
    # Check if NTL is installed
    try
        run(pipeline(`pkg-config --exists ntl`, stdout=devnull, stderr=devnull))
        return true
    catch
        # Try to find NTL headers directly
        for path in ["/usr/include/NTL", "/usr/local/include/NTL", "/opt/homebrew/include/NTL"]
            if isdir(path)
                return true
            end
        end
        return false
    end
end

function get_ntl_flags()
    try
        cflags = read(`pkg-config --cflags ntl`, String) |> strip
        libs = read(`pkg-config --libs ntl`, String) |> strip
        return cflags, libs
    catch
        # Default paths
        return "-I/usr/include", "-L/usr/lib -lntl -lgmp -lm"
    end
end

function build_wrapper()
    println("=" ^ 60)
    println("Building LibNTL Julia Wrapper")
    println("=" ^ 60)

    # Check prerequisites
    println("\n[1/5] Checking prerequisites...")

    if !check_ntl_installed()
        error("""
        NTL library not found!

        Please install NTL:
          Ubuntu/Debian: sudo apt-get install libntl-dev
          macOS:         brew install ntl
          From source:   https://libntl.org/
        """)
    end
    println("  ✓ NTL found")

    jlcxx_dir = find_jlcxx_prefix()
    if !isdir(jlcxx_dir)
        error("JlCxx CMake config not found at: $jlcxx_dir")
    end
    println("  ✓ JlCxx found at: $jlcxx_dir")

    # Create build directory
    println("\n[2/5] Creating build directory...")
    rm(BUILD_DIR, force=true, recursive=true)
    mkpath(BUILD_DIR)
    mkpath(LIB_DIR)
    println("  ✓ Build directory: $BUILD_DIR")

    # Configure with CMake
    println("\n[3/5] Configuring with CMake...")
    cd(BUILD_DIR) do
        cmake_cmd = `cmake
            -DCMAKE_BUILD_TYPE=Release
            -DCMAKE_PREFIX_PATH=$(CxxWrap.prefix_path())
            -DJlCxx_DIR=$jlcxx_dir
            -DCMAKE_INSTALL_PREFIX=$LIB_DIR
            $WRAPPER_DIR`

        run(cmake_cmd)
    end
    println("  ✓ CMake configuration complete")

    # Build
    println("\n[4/5] Compiling...")
    cd(BUILD_DIR) do
        run(`cmake --build . --config Release -- -j$(Sys.CPU_THREADS)`)
    end
    println("  ✓ Compilation complete")

    # Find the built library
    lib_name = Sys.iswindows() ? "libntl_julia.dll" :
               Sys.isapple() ? "libntl_julia.dylib" : "libntl_julia.so"

    lib_path = joinpath(BUILD_DIR, lib_name)
    if !isfile(lib_path)
        # Try alternative locations
        for candidate in [
            joinpath(BUILD_DIR, "Release", lib_name),
            joinpath(BUILD_DIR, "lib", lib_name),
        ]
            if isfile(candidate)
                lib_path = candidate
                break
            end
        end
    end

    if !isfile(lib_path)
        error("Built library not found! Expected at: $lib_path")
    end

    # Copy to lib directory
    final_lib_path = joinpath(LIB_DIR, lib_name)
    cp(lib_path, final_lib_path, force=true)
    println("  ✓ Library installed to: $final_lib_path")

    # Create LocalPreferences.toml
    println("\n[5/5] Creating configuration...")
    prefs_path = joinpath(PROJECT_DIR, "LocalPreferences.toml")
    open(prefs_path, "w") do io
        println(io, "[LibNTL]")
        println(io, "libntl_julia_path = \"$final_lib_path\"")
    end
    println("  ✓ Created: $prefs_path")

    println("\n" * "=" ^ 60)
    println("Build successful!")
    println("=" ^ 60)
    println("\nTo use the compiled library, either:")
    println("  1. Set environment variable:")
    println("     export LIBNTL_JULIA_PATH=\"$final_lib_path\"")
    println("\n  2. Or the LocalPreferences.toml will be used automatically")
    println("\nRestart Julia to use the NTL wrapper.")

    return final_lib_path
end

# Run build if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    build_wrapper()
end
