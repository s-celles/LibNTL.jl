# LibNTL.jl

[![CI](https://github.com/s-celles/LibNTL.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/s-celles/LibNTL.jl/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://s-celles.github.io/LibNTL.jl/stable/)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://s-celles.github.io/LibNTL.jl/dev/)

Julia wrapper for the [NTL (Number Theory Library)](https://libntl.org/) C++ library.

## Features

- **ZZ**: Arbitrary-precision integers with full arithmetic support
- **ZZ_p**: Modular integers (Z/pZ) with thread-local modulus management
- **ZZX**: Polynomials over integers with GCD, derivative, and evaluation

All types integrate seamlessly with Julia's operators and type system.

## Installation

```julia
using Pkg
Pkg.add("LibNTL")
```

### Development Mode

LibNTL works out of the box in **development mode** using pure Julia (BigInt).
This is fully functional but slower than the native NTL library.

### Building the NTL Wrapper (Optional)

For maximum performance, compile the C++ wrapper:

1. Install NTL:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install libntl-dev

   # macOS
   brew install ntl
   ```

2. Build the wrapper:
   ```bash
   cd ~/.julia/dev/LibNTL/deps
   ./build.sh
   ```

3. Restart Julia. If successful, the warning message will disappear.

## Quick Start

```julia
using LibNTL

# Arbitrary-precision integers
a = ZZ(42)
b = ZZ("12345678901234567890")
c = a + b
println("Sum: ", c)

# GCD and extended GCD
d, s, t = gcdx(ZZ(48), ZZ(18))  # d = 6 = 48*s + 18*t

# Modular arithmetic
ZZ_p_init!(ZZ(17))
x = ZZ_p(5)
y = inv(x)  # 5 * 7 = 35 ≡ 1 (mod 17)
println("5^(-1) mod 17 = ", rep(y))

# Context switching for nested moduli
result = with_modulus(ZZ(23)) do
    rep(inv(ZZ_p(7)))
end

# Polynomials
f = ZZX([ZZ(1), ZZ(2), ZZ(1)])  # 1 + 2x + x^2
println("f(3) = ", f(ZZ(3)))  # 16
println("f'(x) = ", derivative(f))  # 2 + 2x
```

## Conversion with BigInt

```julia
# ZZ to BigInt
big_val = convert(BigInt, ZZ(42))
big_val = BigInt(ZZ("999999999999999999"))

# BigInt to ZZ
z = ZZ(big"12345678901234567890")
```

## Documentation

See the [documentation](https://s-celles.github.io/LibNTL.jl/stable/) for:
- Complete API reference
- Tutorial with usage examples
- Type details and operations

## License

MIT License
