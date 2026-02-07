#!/usr/bin/env julia
"""
NTL Tour Example 2.4: Matrix Multiplication

Corresponds to NTL C++ example that demonstrates matrix operations:
```cpp
Mat<ZZ> A, B, C;
SetDims(A, n, n);
SetDims(B, n, n);
// ... fill matrices ...
mul(C, A, B);  // C = A * B
```

This Julia version demonstrates MatZZ construction, indexing, and multiplication.
"""

using LibNTL

println("=== Matrix Multiplication Example ===\n")

# Example 1: 2x2 matrix multiplication
println("Example 1: 2x2 matrices")
A = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
B = MatZZ([ZZ(5) ZZ(6); ZZ(7) ZZ(8)])

println("A = ")
println("  [$(A[1,1]) $(A[1,2])]")
println("  [$(A[2,1]) $(A[2,2])]")

println("B = ")
println("  [$(B[1,1]) $(B[1,2])]")
println("  [$(B[2,1]) $(B[2,2])]")

C = A * B
println("C = A * B = ")
println("  [$(C[1,1]) $(C[1,2])]")
println("  [$(C[2,1]) $(C[2,2])]")

# Verify: [1 2] * [5 6] = [1*5+2*7  1*6+2*8] = [19 22]
#         [3 4]   [7 8]   [3*5+4*7  3*6+4*8]   [43 50]
@assert C[1,1] == ZZ(19) && C[1,2] == ZZ(22)
@assert C[2,1] == ZZ(43) && C[2,2] == ZZ(50)

# Example 2: Using mul! for in-place computation
println("\nExample 2: In-place multiplication with mul!")
result = MatZZ(2, 2)
mul!(result, A, B)
println("Result from mul!: [$(result[1,1]) $(result[1,2]); $(result[2,1]) $(result[2,2])]")
@assert result == C

# Example 3: Matrix-scalar multiplication
println("\nExample 3: Scalar multiplication")
D = A * ZZ(10)
println("A * 10 = ")
println("  [$(D[1,1]) $(D[1,2])]")
println("  [$(D[2,1]) $(D[2,2])]")

# Example 4: 3x3 matrices
println("\nExample 4: 3x3 identity times matrix")
let
    I3 = MatZZ(3, 3)
    for i in 1:3
        I3[i, i] = ZZ(1)
    end

    M = MatZZ([ZZ(1) ZZ(2) ZZ(3); ZZ(4) ZZ(5) ZZ(6); ZZ(7) ZZ(8) ZZ(9)])

    result3 = I3 * M
    println("I * M = M: ", result3 == M)
    @assert result3 == M
end

# Example 5: Large numbers in matrices
println("\nExample 5: Large integer matrices")
let
    big_A = MatZZ([ZZ(10)^50 ZZ(10)^60; ZZ(10)^70 ZZ(10)^80])
    big_B = MatZZ([ZZ(2) ZZ(3); ZZ(4) ZZ(5)])

    big_C = big_A * big_B
    println("Product of large matrices computed successfully")
    println("C[1,1] has $(numbits(big_C[1,1])) bits")
end

println("\nExample completed successfully!")
