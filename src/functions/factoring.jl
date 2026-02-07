"""
Polynomial factorization functions.

Provides factorization algorithms for polynomials over Z.
"""

"""
    factor(f::ZZX) -> (ZZ, Vector{Tuple{ZZX, Int}})

Factor the polynomial f over the integers.

Returns a tuple (content, factors) where:
- content is the content of f (GCD of all coefficients)
- factors is a vector of (factor, multiplicity) pairs

The product of content times all factors raised to their multiplicities equals f.

# Example
```julia
f = ZZX([ZZ(-1), ZZ(0), ZZ(1)])  # x^2 - 1
c, factors = factor(f)
# c = 1, factors = [(x-1, 1), (x+1, 1)]
```
"""
function factor end

if !_USE_NATIVE
    # Pure Julia fallback implementation using trial division
    # This is a simple implementation suitable for small polynomials
    function factor(f::ZZX)
        if iszero(f)
            return (ZZ(0), Tuple{ZZX, Int}[])
        end

        # Extract content
        c = content(f)
        if iszero(c)
            return (ZZ(0), Tuple{ZZX, Int}[])
        end

        # Make primitive
        g = primpart(f)

        # Handle constant polynomial
        if degree(g) == 0
            return (c * constant(g), Tuple{ZZX, Int}[])
        end

        # Make leading coefficient positive
        if leading(g) < ZZ(0)
            g = -g
            c = -c
        end

        factors = Tuple{ZZX, Int}[]

        # Factor out x if it divides g
        x_power = 0
        while degree(g) >= 1 && constant(g) == ZZ(0)
            x_power += 1
            # Divide by x: shift coefficients down
            new_coeffs = ZZ[]
            for i in 1:degree(g)
                push!(new_coeffs, coeff(g, i))
            end
            g = ZZX(new_coeffs)
        end
        if x_power > 0
            push!(factors, (ZZX([ZZ(0), ZZ(1)]), x_power))  # x
        end

        # Now factor the remaining polynomial using trial roots
        # Check integer roots: divisors of constant term
        if degree(g) >= 1
            _find_linear_factors!(g, factors)
        end

        # If there's remaining polynomial of degree >= 1, add it as irreducible
        if degree(g) >= 1
            push!(factors, (g, 1))
        end

        # Sort factors by degree then by coefficients for consistency
        sort!(factors, by = x -> (degree(x[1]), [coeff(x[1], i) for i in 0:degree(x[1])]))

        return (c, factors)
    end

    # Helper: find linear factors by checking integer roots
    function _find_linear_factors!(g::ZZX, factors::Vector{Tuple{ZZX, Int}})
        if degree(g) < 1
            return
        end

        # Get divisors of constant term and leading coefficient
        const_term = abs(constant(g).value)
        lead_coef = abs(leading(g).value)

        if const_term == 0
            return  # Already handled x factors
        end

        # Candidate rational roots are ± (divisors of const) / (divisors of lead)
        const_divisors = _divisors(const_term)
        lead_divisors = _divisors(lead_coef)

        candidates = BigInt[]
        for p in const_divisors
            for q in lead_divisors
                if mod(p, q) == 0
                    r = div(p, q)
                    if !(r in candidates)
                        push!(candidates, r)
                    end
                    if !(-r in candidates)
                        push!(candidates, -r)
                    end
                end
            end
        end

        # Test each candidate
        for root in candidates
            while degree(g) >= 1
                # Evaluate g at root
                val = g(ZZ(root))
                if val == ZZ(0)
                    # (x - root) is a factor
                    linear = ZZX([ZZ(-root), ZZ(1)])

                    # Check if this factor is already in the list
                    found = false
                    for i in eachindex(factors)
                        if factors[i][1] == linear
                            factors[i] = (linear, factors[i][2] + 1)
                            found = true
                            break
                        end
                    end
                    if !found
                        push!(factors, (linear, 1))
                    end

                    # Divide g by (x - root)
                    g_new = div(g, linear)
                    # Update g in-place by modifying its coefficients
                    for i in 0:degree(g_new)
                        setcoeff!(g, i, coeff(g_new, i))
                    end
                    # Trim higher coefficients
                    for i in (degree(g_new)+1):degree(g)
                        setcoeff!(g, i, ZZ(0))
                    end
                else
                    break
                end
            end
        end
    end

    # Helper: get all positive divisors of n
    function _divisors(n::BigInt)
        if n == 0
            return BigInt[1]
        end
        n = abs(n)
        divs = BigInt[]
        i = BigInt(1)
        while i * i <= n
            if mod(n, i) == 0
                push!(divs, i)
                if i * i != n
                    push!(divs, div(n, i))
                end
            end
            i += 1
        end
        sort!(divs)
        return divs
    end
end
