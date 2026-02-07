"""
Polynomial construction functions.

Provides functions for constructing special polynomials.
"""

"""
    cyclotomic(n::Integer) -> ZZX

Compute the n-th cyclotomic polynomial Φₙ(x).

The cyclotomic polynomial Φₙ(x) is the minimal polynomial of primitive n-th roots
of unity over the rationals. It satisfies:
- xⁿ - 1 = ∏_{d|n} Φ_d(x)
- degree(Φₙ) = φ(n) (Euler's totient function)

# Examples
```julia
cyclotomic(1)   # x - 1
cyclotomic(2)   # x + 1
cyclotomic(3)   # x² + x + 1
cyclotomic(4)   # x² + 1
cyclotomic(6)   # x² - x + 1
```
"""
function cyclotomic end

if !_USE_NATIVE
    function cyclotomic(n::Integer)
        n >= 1 || throw(DomainError(n, "n must be a positive integer"))

        # Use the recursive formula:
        # Φₙ(x) = (xⁿ - 1) / ∏_{d|n, d<n} Φ_d(x)

        # Special cases for small n
        if n == 1
            return ZZX([ZZ(-1), ZZ(1)])  # x - 1
        end

        # Build x^n - 1
        coeffs = [ZZ(0) for _ in 1:(n+1)]
        coeffs[1] = ZZ(-1)
        coeffs[n+1] = ZZ(1)
        xn_minus_1 = ZZX(coeffs)

        # Divide by Φ_d for all proper divisors d of n
        result = xn_minus_1
        for d in 1:(n-1)
            if mod(n, d) == 0
                phi_d = cyclotomic(d)
                result = div(result, phi_d)
            end
        end

        return result
    end
end
