"""
Development mode implementation for VecZZ using Julia's Vector{ZZ} as internal storage.
"""

"""
    VecZZ

Vector of arbitrary-precision integers. In development mode, this is a wrapper around Vector{ZZ}.
"""
mutable struct VecZZ <: AbstractVec{ZZ}
    data::Vector{ZZ}
    VecZZ(v::Vector{ZZ}) = new(v)
end

# Constructors
VecZZ() = VecZZ(ZZ[])
VecZZ(n::Integer) = VecZZ([ZZ(0) for _ in 1:n])
VecZZ(v::Vector{<:Integer}) = VecZZ([ZZ(x) for x in v])
VecZZ(v::AbstractVector{ZZ}) = VecZZ(collect(v))

# AbstractVector interface
Base.size(v::VecZZ) = (length(v.data),)
Base.length(v::VecZZ) = length(v.data)
Base.isempty(v::VecZZ) = isempty(v.data)

function Base.getindex(v::VecZZ, i::Int)
    @boundscheck checkbounds(v.data, i)
    return v.data[i]
end

function Base.setindex!(v::VecZZ, x::ZZ, i::Int)
    @boundscheck checkbounds(v.data, i)
    v.data[i] = x
    return v
end

Base.setindex!(v::VecZZ, x::Integer, i::Int) = setindex!(v, ZZ(x), i)

# IndexStyle for efficient iteration
Base.IndexStyle(::Type{VecZZ}) = IndexLinear()

# Iteration
Base.iterate(v::VecZZ) = isempty(v.data) ? nothing : (v.data[1], 2)
Base.iterate(v::VecZZ, state::Int) = state > length(v.data) ? nothing : (v.data[state], state + 1)

# Mutation
function Base.push!(v::VecZZ, x::ZZ)
    push!(v.data, x)
    return v
end
Base.push!(v::VecZZ, x::Integer) = push!(v, ZZ(x))

function Base.resize!(v::VecZZ, n::Integer)
    current = length(v.data)
    if n > current
        # Extend with zeros
        for _ in 1:(n - current)
            push!(v.data, ZZ(0))
        end
    elseif n < current
        # Shrink
        resize!(v.data, n)
    end
    return v
end

# Equality
Base.:(==)(v1::VecZZ, v2::VecZZ) = v1.data == v2.data

# Copy
Base.copy(v::VecZZ) = VecZZ(copy(v.data))
Base.deepcopy_internal(v::VecZZ, dict::IdDict) = VecZZ([copy(x) for x in v.data])

# Display in NTL format: [1 2 3]
function Base.show(io::IO, v::VecZZ)
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
Base.similar(v::VecZZ) = VecZZ(length(v))
Base.similar(v::VecZZ, ::Type{ZZ}) = VecZZ(length(v))
Base.similar(v::VecZZ, dims::Dims) = VecZZ(dims[1])

# eltype
Base.eltype(::Type{VecZZ}) = ZZ
