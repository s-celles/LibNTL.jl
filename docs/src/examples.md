# NTL Tour Examples

This page demonstrates LibNTL.jl by comparing NTL C++ examples with their Julia equivalents.
All examples are from the [NTL Tour](https://libntl.org/doc/tour.html).

## Tour Example 1: Big Integers

### Example 1.1: Basic Arithmetic

**C++ (NTL)**:
```cpp
#include <NTL/ZZ.h>
using namespace NTL;

int main() {
   ZZ a, b, c;
   cin >> a >> b;
   c = a + b;
   cout << c << endl;
}
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

a = ZZ("12345678901234567890")
b = ZZ("98765432109876543210")
c = a + b
println(c)  # 111111111011111111100
```

### Example 1.2: Sum of Squares

**C++ (NTL)**:
```cpp
ZZ sum = ZZ(0);
for (long i = 1; i <= 100; i++) {
   sum += ZZ(i) * ZZ(i);
}
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

sum = ZZ(0)
for i in 1:100
    sum += ZZ(i) * ZZ(i)
end
println(sum)  # 338350
```

### Example 1.3: Modular Exponentiation

**C++ (NTL)**:
```cpp
ZZ a, e, n;
PowerMod(result, a, e, n);
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

a = ZZ(2)
e = ZZ(100)
n = ZZ(1000000007)
result = PowerMod(a, e, n)
println(result)  # 976371285
```

### Example 1.4: Primality Testing

**C++ (NTL)**:
```cpp
ZZ n;
if (ProbPrime(n))
   cout << n << " is probably prime" << endl;
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

n = ZZ("170141183460469231731687303715884105727")  # 2^127 - 1
if ProbPrime(n)
    println("$n is probably prime")
end
```

## Tour Example 2: Vectors and Matrices

### Example 2.1: Vector Sum (0-indexed style)

**C++ (NTL)**:
```cpp
Vec<ZZ> v;
v.SetLength(5);
ZZ sum = ZZ(0);
for (long i = 0; i < v.length(); i++)
   sum += v[i];
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

v = VecZZ([ZZ(1), ZZ(2), ZZ(3), ZZ(4), ZZ(5)])
sum = ZZ(0)
for i in 0:length(v)-1
    sum += v(i)  # 0-indexed access via callable
end
println(sum)  # 15
```

### Example 2.2: Vector Sum (1-indexed Julia style)

**Julia (LibNTL.jl)**:
```julia
using LibNTL

v = VecZZ([ZZ(1), ZZ(2), ZZ(3), ZZ(4), ZZ(5)])
sum = ZZ(0)
for x in v  # Iterator access
    sum += x
end
println(sum)  # 15
```

### Example 2.3: Matrix Multiplication

**C++ (NTL)**:
```cpp
Mat<ZZ> A, B, C;
mul(C, A, B);
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

A = MatZZ(2, 2)
A[1,1] = ZZ(1); A[1,2] = ZZ(2)
A[2,1] = ZZ(3); A[2,2] = ZZ(4)

B = MatZZ(2, 2)
B[1,1] = ZZ(5); B[1,2] = ZZ(6)
B[2,1] = ZZ(7); B[2,2] = ZZ(8)

C = A * B
println("C[1,1] = ", C[1,1])  # 19
println("C[1,2] = ", C[1,2])  # 22
println("C[2,1] = ", C[2,1])  # 43
println("C[2,2] = ", C[2,2])  # 50
```

## Tour Example 3: Polynomials over Z

### Example 3.1: Polynomial Factorization

**C++ (NTL)**:
```cpp
ZZX f;
Vec<Pair<ZZX, long>> factors;
ZZ c;
factor(c, factors, f);
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

# x^4 - 1 = (x-1)(x+1)(x^2+1)
f = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(0), ZZ(1)])
content_val, factors = factor(f)

println("Content: ", content_val)
for (poly, mult) in factors
    println("Factor: ", poly, " with multiplicity ", mult)
end
```

### Example 3.2: Cyclotomic Polynomials

**C++ (NTL)**:
```cpp
ZZX phi;
CyclotomicPoly(phi, 12);  // Phi_12(x)
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

phi = cyclotomic(12)  # Phi_12(x) = x^4 - x^2 + 1
println("Phi_12(x) = ", phi)
println("Degree: ", degree(phi))  # 4
```

## Tour Example 4: Modular Polynomials

### Example 4.1: Polynomial Factorization mod p

**C++ (NTL)**:
```cpp
ZZ_p::init(ZZ(17));
ZZ_pX f;
// Build f(x) = x^4 - 1
SetCoeff(f, 4, 1);
SetCoeff(f, 0, -1);
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

with_modulus(ZZ(17)) do
    # x^4 - 1 = x^4 + 16 (mod 17)
    f = ZZ_pX([ZZ_p(16), ZZ_p(0), ZZ_p(0), ZZ_p(0), ZZ_p(1)])
    println("f(x) = ", f)

    # Check roots
    for x in 0:16
        if iszero(f(ZZ_p(x)))
            println("Root: ", x)
        end
    end
end
```

### Example 4.2: Irreducibility Testing

**C++ (NTL)**:
```cpp
ZZ_p::init(ZZ(2));
ZZ_pX f;
// f = x^2 + x + 1
SetCoeff(f, 0, 1);
SetCoeff(f, 1, 1);
SetCoeff(f, 2, 1);
if (DetIrredTest(f))
   cout << "Irreducible!" << endl;
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

with_modulus(ZZ(2)) do
    # x^2 + x + 1 is irreducible over GF(2)
    f = ZZ_pX([ZZ_p(1), ZZ_p(1), ZZ_p(1)])
    println("f = ", f)
    println("Irreducible: ", is_irreducible(f))  # true
end
```

### Example 4.3: Context Management

**C++ (NTL)**:
```cpp
ZZ_p::init(ZZ(17));
ZZ_pContext context;
context.save();
ZZ_p::init(ZZ(23));
// ... work with modulus 23 ...
context.restore();
```

**Julia (LibNTL.jl)**:
```julia
using LibNTL

ZZ_p_init!(ZZ(17))
println("Outer modulus: ", ZZ_p_modulus())

with_modulus(ZZ(23)) do
    println("Inner modulus: ", ZZ_p_modulus())
    # Work with modulus 23
end

println("Restored modulus: ", ZZ_p_modulus())  # Back to 17
```

## Running the Examples

All examples are available as runnable scripts in the `examples/` directory:

```julia
# From the package directory
include("examples/tour_ex1/basic_arithmetic.jl")
include("examples/tour_ex2/matrix_multiply.jl")
include("examples/tour_ex3/factorization.jl")
include("examples/tour_ex4/poly_factor_mod_p.jl")
```

Or run them as tests:

```julia
using Pkg
Pkg.test("LibNTL")
```
