"""
Development mode implementation for VecGF2 (vectors over GF(2)) using BitVector.
"""

"""
    VecGF2

Vector over GF(2). Uses BitVector for efficient storage.
"""
mutable struct VecGF2 <: AbstractVec{GF2}
    data::BitVector
    VecGF2(v::BitVector) = new(v)
end

# Constructors
VecGF2() = VecGF2(BitVector())
VecGF2(n::Integer) = VecGF2(falses(n))
VecGF2(v::Vector{<:Integer}) = VecGF2(BitVector([isodd(x) for x in v]))
VecGF2(v::Vector{GF2}) = VecGF2(BitVector([x.value for x in v]))
VecGF2(v::Vector{Bool}) = VecGF2(BitVector(v))

# AbstractVector interface
Base.size(v::VecGF2) = (length(v.data),)
Base.length(v::VecGF2) = length(v.data)
Base.isempty(v::VecGF2) = isempty(v.data)

function Base.getindex(v::VecGF2, i::Int)
    @boundscheck checkbounds(v.data, i)
    return GF2(v.data[i])
end

function Base.setindex!(v::VecGF2, x::GF2, i::Int)
    @boundscheck checkbounds(v.data, i)
    v.data[i] = x.value
    return v
end

Base.setindex!(v::VecGF2, x::Integer, i::Int) = setindex!(v, GF2(x), i)
Base.setindex!(v::VecGF2, x::Bool, i::Int) = setindex!(v, GF2(x), i)

# IndexStyle
Base.IndexStyle(::Type{VecGF2}) = IndexLinear()

# Iteration
Base.iterate(v::VecGF2) = isempty(v.data) ? nothing : (GF2(v.data[1]), 2)
Base.iterate(v::VecGF2, state::Int) = state > length(v.data) ? nothing : (GF2(v.data[state]), state + 1)

# Mutation
function Base.push!(v::VecGF2, x::GF2)
    push!(v.data, x.value)
    return v
end
Base.push!(v::VecGF2, x::Integer) = push!(v, GF2(x))
Base.push!(v::VecGF2, x::Bool) = push!(v, GF2(x))

function Base.resize!(v::VecGF2, n::Integer)
    resize!(v.data, n)
    return v
end

# Equality
Base.:(==)(v1::VecGF2, v2::VecGF2) = v1.data == v2.data

# Copy
Base.copy(v::VecGF2) = VecGF2(copy(v.data))
Base.deepcopy_internal(v::VecGF2, dict::IdDict) = copy(v)

# Display in NTL format
function Base.show(io::IO, v::VecGF2)
    print(io, "[")
    for i in eachindex(v.data)
        if i > 1
            print(io, " ")
        end
        print(io, Int(v.data[i]))
    end
    print(io, "]")
end

# Similar
Base.similar(v::VecGF2) = VecGF2(length(v))
Base.similar(v::VecGF2, ::Type{GF2}) = VecGF2(length(v))
Base.similar(v::VecGF2, dims::Dims) = VecGF2(dims[1])

# eltype
Base.eltype(::Type{VecGF2}) = GF2

# Vector arithmetic
function Base.:+(v1::VecGF2, v2::VecGF2)
    @assert length(v1) == length(v2) "Vector lengths must match"
    return VecGF2(xor.(v1.data, v2.data))
end

Base.:-(v1::VecGF2, v2::VecGF2) = v1 + v2  # Same as addition in GF(2)
Base.:-(v::VecGF2) = copy(v)  # Negation is identity

# 0-indexed access
(v::VecGF2)(i::Integer) = v[i + 1]

# Inner product
function inner_product(a::VecGF2, b::VecGF2)
    @assert length(a) == length(b) "Vector lengths must match"
    result = false
    for i in eachindex(a.data)
        if a.data[i] && b.data[i]
            result = xor(result, true)
        end
    end
    return GF2(result)
end
