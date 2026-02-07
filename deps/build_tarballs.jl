# Build script for LibNTL_jll
#
# This creates the CxxWrap wrapper for NTL that bridges C++ to Julia.
# Submit to Yggdrasil to get automated builds for all platforms.
#
# Test locally with:
#   julia build_tarballs.jl --debug --verbose

using BinaryBuilder, Pkg

name = "LibNTL"
version = v"0.1.0"

# Source: our wrapper code
sources = [
    DirectorySource("./LibNTLBuilder/bundled/wrapper"),
]

# Build script
script = raw"""
cd $WORKSPACE/srcdir

# Create build directory
mkdir -p build && cd build

# Configure with CMake
cmake .. \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=${prefix} \
    -DJlCxx_DIR=${prefix}/lib/cmake/JlCxx

# Build and install
cmake --build . --parallel ${nproc}
cmake --install .
"""

# Platforms supported by libcxxwrap_julia_jll
# We need to match Julia version for CxxWrap ABI compatibility
julia_versions = [v"1.6.3", v"1.7", v"1.8", v"1.9", v"1.10", v"1.11", v"1.12"]

platforms = vcat(
    [Platform("x86_64", "linux"; libc="glibc", julia_version=v) for v in julia_versions],
    [Platform("aarch64", "linux"; libc="glibc", julia_version=v) for v in julia_versions],
    [Platform("x86_64", "macos"; julia_version=v) for v in julia_versions],
    [Platform("aarch64", "macos"; julia_version=v) for v in julia_versions],
    [Platform("x86_64", "windows"; julia_version=v) for v in julia_versions],
)

# Expand C++ string ABI variants
platforms = expand_cxxstring_abis(platforms)

# Products: our shared library
products = [
    LibraryProduct("libntl_julia", :libntl_julia),
]

# Dependencies
dependencies = [
    # NTL library
    Dependency("ntl_jll"; compat="~10.5"),
    # CxxWrap runtime (must match Julia version)
    BuildDependency("libcxxwrap_julia_jll"),
    Dependency("libcxxwrap_julia_jll"; compat="~0.13"),
    # GMP (required by NTL)
    Dependency("GMP_jll"; compat="6"),
]

# Build the tarballs
build_tarballs(
    ARGS,
    name,
    version,
    sources,
    script,
    platforms,
    products,
    dependencies;
    julia_compat="1.6",
    preferred_gcc_version=v"9",
)
