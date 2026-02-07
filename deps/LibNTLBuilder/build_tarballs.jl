# Build script for LibNTL_jll
#
# This script is used by BinaryBuilder.jl to build cross-platform binaries
# for the LibNTL Julia wrapper library.
#
# To build locally for testing:
#   julia --project=. build_tarballs.jl --deploy=local
#
# To submit to Yggdrasil:
#   Follow the Yggdrasil contribution guidelines

using BinaryBuilder, Pkg

name = "LibNTL"
version = v"0.1.0"

# Collection of sources required to build LibNTL
sources = [
    DirectorySource("bundled"),
]

# Bash script to build the wrapper
script = raw"""
cd $WORKSPACE/srcdir/wrapper

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$prefix \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DJulia_PREFIX=${prefix} \
    -DNTL_DIR=${prefix}

# Build and install
make -j${nproc}
make install
"""

# Platforms we'll build for
# Note: Windows is excluded due to ntl_jll limitations
platforms = supported_platforms()
filter!(p -> !Sys.iswindows(p), platforms)

# Expand C++ string ABI
platforms = expand_cxxstring_abis(platforms)

# Dependencies
dependencies = [
    Dependency("ntl_jll"),
    Dependency("libcxxwrap_julia_jll"),
    BuildDependency("libjulia_jll"),
]

# Products (the shared library we're building)
products = [
    LibraryProduct("libntl_julia", :libntl_julia),
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
    julia_compat = "1.6",
    preferred_gcc_version = v"9",
)
