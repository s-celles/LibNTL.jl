"""
Development mode implementation for VecZZ_p using Julia's Vector{ZZ_p} as internal storage.
"""

"""
    VecZZ_p

Vector of integers modulo p. In development mode, this is a wrapper around Vector{ZZ_p}.
Operations are performed in the current ZZ_p modulus context.
"""
mutable struct VecZZ_p <: AbstractVec{ZZ_p}
    data::Vector{ZZ_p}
    VecZZ_p(v::Vector{ZZ_p}) = new(v)
end

# Constructors
VecZZ_p() = VecZZ_p(ZZ_p[])
VecZZ_p(n::Integer) = VecZZ_p([ZZ_p(0) for _ in 1:n])
VecZZ_p(v::Vector{<:Integer}) = VecZZ_p([ZZ_p(x) for x in v])
VecZZ_p(v::AbstractVector{ZZ_p}) = VecZZ_p(collect(v))

# AbstractVector interface
Base.size(v::VecZZ_p) = (length(v.data),)
Base.length(v::VecZZ_p) = length(v.data)
Base.isempty(v::VecZZ_p) = isempty(v.data)

function Base.getindex(v::VecZZ_p, i::Int)
    @boundscheck checkbounds(v.data, i)
    return v.data[i]
end

function Base.setindex!(v::VecZZ_p, x::ZZ_p, i::Int)
    @boundscheck checkbounds(v.data, i)
    v.data[i] = x
    return v
end

Base.setindex!(v::VecZZ_p, x::Integer, i::Int) = setindex!(v, ZZ_p(x), i)

# IndexStyle for efficient iteration
Base.IndexStyle(::Type{VecZZ_p}) = IndexLinear()

# Iteration
Base.iterate(v::VecZZ_p) = isempty(v.data) ? nothing : (v.data[1], 2)
Base.iterate(v::VecZZ_p, state::Int) = state > length(v.data) ? nothing : (v.data[state], state + 1)

# Mutation
function Base.push!(v::VecZZ_p, x::ZZ_p)
    push!(v.data, x)
    return v
end
Base.push!(v::VecZZ_p, x::Integer) = push!(v, ZZ_p(x))

function Base.resize!(v::VecZZ_p, n::Integer)
    current = length(v.data)
    if n > current
        # Extend with zeros
        for _ in 1:(n - current)
            push!(v.data, ZZ_p(0))
        end
    elseif n < current
        # Shrink
        resize!(v.data, n)
    end
    return v
end

# Equality
Base.:(==)(v1::VecZZ_p, v2::VecZZ_p) = v1.data == v2.data

# Copy
Base.copy(v::VecZZ_p) = VecZZ_p(copy(v.data))
Base.deepcopy_internal(v::VecZZ_p, dict::IdDict) = VecZZ_p([copy(x) for x in v.data])

# Display in NTL format: [1 2 3]
function Base.show(io::IO, v::VecZZ_p)
    print(io, "[")
    for i in eachindex(v.data)
        if i > 1
            print(io, " ")
        end
        print(io, v.data[i])
    end
    print(io, "]")
end

# Similar for broadcasting
Base.similar(v::VecZZ_p) = VecZZ_p(length(v))
Base.similar(v::VecZZ_p, ::Type{ZZ_p}) = VecZZ_p(length(v))
Base.similar(v::VecZZ_p, dims::Dims) = VecZZ_p(dims[1])

# eltype
Base.eltype(::Type{VecZZ_p}) = ZZ_p

# Vector arithmetic
function Base.:+(v1::VecZZ_p, v2::VecZZ_p)
    @assert length(v1) == length(v2) "Vector lengths must match"
    return VecZZ_p([v1[i] + v2[i] for i in 1:length(v1)])
end

function Base.:-(v1::VecZZ_p, v2::VecZZ_p)
    @assert length(v1) == length(v2) "Vector lengths must match"
    return VecZZ_p([v1[i] - v2[i] for i in 1:length(v1)])
end

Base.:-(v::VecZZ_p) = VecZZ_p([-x for x in v.data])

# Scalar multiplication
Base.:*(c::ZZ_p, v::VecZZ_p) = VecZZ_p([c * x for x in v.data])
Base.:*(v::VecZZ_p, c::ZZ_p) = c * v
Base.:*(c::Integer, v::VecZZ_p) = ZZ_p(c) * v
Base.:*(v::VecZZ_p, c::Integer) = v * ZZ_p(c)

# 0-indexed access (NTL style) via callable syntax
(v::VecZZ_p)(i::Integer) = v[i + 1]

# Inner product
"""
    inner_product(a::VecZZ_p, b::VecZZ_p) -> ZZ_p

Compute the inner product of two vectors over Z/pZ.
"""
function inner_product(a::VecZZ_p, b::VecZZ_p)
    @assert length(a) == length(b) "Vector lengths must match"
    result = ZZ_p(0)
    for i in 1:length(a)
        result = result + a[i] * b[i]
    end
    return result
end

"""
    inner_product_zz(a::VecZZ_p, b::VecZZ_p) -> ZZ_p

Compute the inner product with delayed reduction (accumulate in ZZ, reduce once at end).
This is more efficient for large vectors.
"""
function inner_product_zz(a::VecZZ_p, b::VecZZ_p)
    @assert length(a) == length(b) "Vector lengths must match"
    accum = ZZ(0)
    for i in 1:length(a)
        accum += rep(a[i]) * rep(b[i])
    end
    return ZZ_p(accum)
end
