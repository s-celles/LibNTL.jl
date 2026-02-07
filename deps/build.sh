#!/bin/bash
# Build script for LibNTL C++ wrapper
#
# Prerequisites:
#   - NTL library: sudo apt-get install libntl-dev (Ubuntu/Debian)
#                  brew install ntl (macOS)
#   - CMake 3.10+
#   - C++17 compatible compiler

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WRAPPER_DIR="$SCRIPT_DIR/LibNTLBuilder/bundled/wrapper"
BUILD_DIR="$SCRIPT_DIR/build"
LIB_DIR="$SCRIPT_DIR/lib"

echo "============================================================"
echo "Building LibNTL Julia Wrapper"
echo "============================================================"

# Check for NTL
echo -e "\n[1/5] Checking prerequisites..."
if ! pkg-config --exists ntl 2>/dev/null; then
    if [ ! -d "/usr/include/NTL" ] && [ ! -d "/usr/local/include/NTL" ] && [ ! -d "/opt/homebrew/include/NTL" ]; then
        echo "ERROR: NTL library not found!"
        echo ""
        echo "Please install NTL:"
        echo "  Ubuntu/Debian: sudo apt-get install libntl-dev"
        echo "  macOS:         brew install ntl"
        echo "  From source:   https://libntl.org/"
        exit 1
    fi
fi
echo "  ✓ NTL found"

# Get JlCxx path from Julia
JLCXX_PREFIX=$(julia --project="$PROJECT_DIR" -e 'using CxxWrap; print(CxxWrap.prefix_path())')
JLCXX_DIR="$JLCXX_PREFIX/lib/cmake/JlCxx"
if [ ! -d "$JLCXX_DIR" ]; then
    JLCXX_DIR="$JLCXX_PREFIX/share/cmake/JlCxx"
fi
echo "  ✓ JlCxx found at: $JLCXX_DIR"

# Create directories
echo -e "\n[2/5] Creating build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$LIB_DIR"
echo "  ✓ Build directory: $BUILD_DIR"

# Configure
echo -e "\n[3/5] Configuring with CMake..."
cd "$BUILD_DIR"
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$JLCXX_PREFIX" \
    -DJlCxx_DIR="$JLCXX_DIR" \
    -DCMAKE_INSTALL_PREFIX="$LIB_DIR" \
    "$WRAPPER_DIR"
echo "  ✓ CMake configuration complete"

# Build
echo -e "\n[4/5] Compiling..."
cmake --build . --config Release -- -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
echo "  ✓ Compilation complete"

# Find and copy library
if [ "$(uname)" = "Darwin" ]; then
    LIB_NAME="libntl_julia.dylib"
else
    LIB_NAME="libntl_julia.so"
fi

cp "$BUILD_DIR/$LIB_NAME" "$LIB_DIR/$LIB_NAME"
FINAL_LIB_PATH="$LIB_DIR/$LIB_NAME"
echo "  ✓ Library installed to: $FINAL_LIB_PATH"

# Create LocalPreferences.toml
echo -e "\n[5/5] Creating configuration..."
cat > "$PROJECT_DIR/LocalPreferences.toml" << EOF
[LibNTL]
libntl_julia_path = "$FINAL_LIB_PATH"
EOF
echo "  ✓ Created: $PROJECT_DIR/LocalPreferences.toml"

echo -e "\n============================================================"
echo "Build successful!"
echo "============================================================"
echo ""
echo "Restart Julia to use the NTL wrapper."
echo ""
echo "To verify: julia --project=. -e 'using LibNTL'"
echo "(No warning = using NTL wrapper)"
