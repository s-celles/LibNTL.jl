#!/usr/bin/env julia
"""
Tour Example 6: Arbitrary-Precision Floating Point (RR)

This example demonstrates the RR type for high-precision
floating-point arithmetic, useful for numerical algorithms
that require more precision than Float64 can provide.

Corresponds to NTL tour example 6:
https://libntl.org/doc/tour-ex6.html
"""

using LibNTL

function main()
    println("=== Arbitrary-Precision Floating Point (RR) ===\n")

    # Example 1: Basic precision control
    println("Example 1: Precision settings")
    println("  Default precision: ", RR_precision(), " bits")
    println("  Default output precision: ", RR_OutputPrecision(), " decimal digits")

    # Set higher precision
    RR_SetPrecision!(500)  # 500 bits ≈ 150 decimal digits
    RR_SetOutputPrecision!(50)
    println("  New precision: ", RR_precision(), " bits")
    println("  New output precision: ", RR_OutputPrecision(), " decimal digits")
    println()

    # Example 2: Computing π
    println("Example 2: Computing π")
    pi_val = RR_pi()
    println("  π = ", pi_val)

    # Verify with known digits
    println("  First 50 decimal places of π:")
    println("  3.14159265358979323846264338327950288419716939937510")
    println()

    # Example 3: Sum of squares
    println("Example 3: Sum of squares with high precision")
    RR_SetOutputPrecision!(20)

    values = [RR("0.1"), RR("0.2"), RR("0.3"), RR("0.4"), RR("0.5")]
    println("  Values: 0.1, 0.2, 0.3, 0.4, 0.5")

    acc = RR(0.0)
    for v in values
        acc = acc + v * v
    end
    println("  Sum of squares = ", acc)
    println("  Expected: 0.01 + 0.04 + 0.09 + 0.16 + 0.25 = 0.55")
    println()

    # Example 4: Compare with Float64 precision loss
    println("Example 4: Precision comparison with Float64")

    # Compute (1 + 10^-15) - 1 in Float64 vs RR
    println("  Computing (1 + 10⁻¹⁵) - 1:")

    # Float64
    f64_result = (1.0 + 1e-15) - 1.0
    println("  Float64 result: ", f64_result)

    # RR with high precision
    RR_SetPrecision!(100)
    one_rr = RR(1.0)
    tiny = RR("1e-15")
    rr_result = (one_rr + tiny) - one_rr
    RR_SetOutputPrecision!(20)
    println("  RR result: ", rr_result)
    println()

    # Example 5: Mathematical functions
    println("Example 5: Mathematical functions")
    RR_SetPrecision!(200)
    RR_SetOutputPrecision!(30)

    x = RR(2.0)
    println("  x = ", x)
    println("  sqrt(x) = ", sqrt(x))
    println("  exp(1) = ", exp(RR(1.0)))
    println("  log(e) = ", log(exp(RR(1.0))))
    println("  sin(π/6) = ", sin(RR_pi() / RR(6.0)))
    println("  cos(π/3) = ", cos(RR_pi() / RR(3.0)))
    println()

    # Example 6: Computing e = Σ 1/n!
    println("Example 6: Computing e using series Σ 1/n!")
    RR_SetPrecision!(500)
    RR_SetOutputPrecision!(50)

    e_approx = RR(0.0)
    factorial_n = RR(1.0)

    for n in 0:100
        if n > 0
            factorial_n = factorial_n * RR(Float64(n))
        end
        term = RR(1.0) / factorial_n
        e_approx = e_approx + term
    end

    println("  e (100 terms) = ", e_approx)
    println("  exp(1) directly = ", exp(RR(1.0)))
    println()

    # Example 7: Large numbers
    println("Example 7: Large number arithmetic")
    RR_SetPrecision!(200)
    RR_SetOutputPrecision!(20)

    # Compute sqrt(2) * 10^100
    big_val = sqrt(RR(2.0)) * RR(10.0)^100
    println("  sqrt(2) * 10^100 ≈ ", big_val)

    # Compute log(very large number)
    huge = RR(10.0)^1000
    log_huge = log(huge)
    println("  log(10^1000) = ", log_huge)
    println("  Expected: 1000 * log(10) ≈ 2302.585...")
    println()

    # Example 8: Precision in iterative algorithms
    println("Example 8: Newton's method for sqrt(2)")
    RR_SetPrecision!(500)
    RR_SetOutputPrecision!(50)

    # Newton's method: x_{n+1} = (x_n + 2/x_n) / 2
    x = RR(1.0)  # Initial guess
    two = RR(2.0)

    println("  Newton iterations for sqrt(2):")
    for i in 1:10
        x = (x + two / x) / two
        if i <= 5 || i == 10
            println("    Iteration $i: ", x)
        elseif i == 6
            println("    ...")
        end
    end

    println("  Direct sqrt(2) = ", sqrt(two))

    println("\nExample completed successfully!")
end

main()
