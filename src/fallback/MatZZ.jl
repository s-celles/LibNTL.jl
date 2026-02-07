"""
Development mode implementation for MatZZ using Julia's Matrix{ZZ} as internal storage.
"""

"""
    MatZZ

Matrix of arbitrary-precision integers. In development mode, this is a wrapper around Matrix{ZZ}.
"""
mutable struct MatZZ <: AbstractMat{ZZ}
    data::Matrix{ZZ}
    MatZZ(m::Matrix{ZZ}) = new(m)
end

# Constructors
MatZZ() = MatZZ(Matrix{ZZ}(undef, 0, 0))
MatZZ(nrows::Integer, ncols::Integer) = MatZZ([ZZ(0) for _ in 1:nrows, _ in 1:ncols])
MatZZ(m::Matrix{<:Integer}) = MatZZ([ZZ(m[i, j]) for i in axes(m, 1), j in axes(m, 2)])
MatZZ(m::AbstractMatrix{ZZ}) = MatZZ(Matrix{ZZ}(m))

# AbstractMatrix interface
Base.size(m::MatZZ) = size(m.data)
Base.size(m::MatZZ, d::Integer) = size(m.data, d)
Base.length(m::MatZZ) = length(m.data)

# NTL-style accessors
nrows(m::MatZZ) = size(m, 1)
ncols(m::MatZZ) = size(m, 2)

function Base.getindex(m::MatZZ, i::Int, j::Int)
    @boundscheck checkbounds(m.data, i, j)
    return m.data[i, j]
end

function Base.setindex!(m::MatZZ, x::ZZ, i::Int, j::Int)
    @boundscheck checkbounds(m.data, i, j)
    m.data[i, j] = x
    return m
end

Base.setindex!(m::MatZZ, x::Integer, i::Int, j::Int) = setindex!(m, ZZ(x), i, j)

# IndexStyle
Base.IndexStyle(::Type{MatZZ}) = IndexCartesian()

# Equality
Base.:(==)(m1::MatZZ, m2::MatZZ) = m1.data == m2.data

# Copy
Base.copy(m::MatZZ) = MatZZ(copy(m.data))
Base.deepcopy_internal(m::MatZZ, dict::IdDict) = MatZZ([copy(m.data[i, j]) for i in axes(m.data, 1), j in axes(m.data, 2)])

# Arithmetic: Addition
function Base.:+(m1::MatZZ, m2::MatZZ)
    @boundscheck size(m1) == size(m2) || throw(DimensionMismatch("Matrix dimensions must match"))
    result = MatZZ(nrows(m1), ncols(m1))
    for i in 1:nrows(m1), j in 1:ncols(m1)
        result[i, j] = m1[i, j] + m2[i, j]
    end
    return result
end

# Arithmetic: Subtraction
function Base.:-(m1::MatZZ, m2::MatZZ)
    @boundscheck size(m1) == size(m2) || throw(DimensionMismatch("Matrix dimensions must match"))
    result = MatZZ(nrows(m1), ncols(m1))
    for i in 1:nrows(m1), j in 1:ncols(m1)
        result[i, j] = m1[i, j] - m2[i, j]
    end
    return result
end

# Arithmetic: Negation
function Base.:-(m::MatZZ)
    result = MatZZ(nrows(m), ncols(m))
    for i in 1:nrows(m), j in 1:ncols(m)
        result[i, j] = -m[i, j]
    end
    return result
end

# Arithmetic: Matrix multiplication
function Base.:*(m1::MatZZ, m2::MatZZ)
    @boundscheck ncols(m1) == nrows(m2) || throw(DimensionMismatch("Matrix dimensions must be compatible for multiplication"))
    result = MatZZ(nrows(m1), ncols(m2))
    mul!(result, m1, m2)
    return result
end

# Arithmetic: Scalar multiplication
function Base.:*(m::MatZZ, s::ZZ)
    result = MatZZ(nrows(m), ncols(m))
    for i in 1:nrows(m), j in 1:ncols(m)
        result[i, j] = m[i, j] * s
    end
    return result
end

Base.:*(s::ZZ, m::MatZZ) = m * s
Base.:*(m::MatZZ, s::Integer) = m * ZZ(s)
Base.:*(s::Integer, m::MatZZ) = ZZ(s) * m

# In-place matrix multiplication
# Uses mul! imported in LibNTL main module
function mul!(C::MatZZ, A::MatZZ, B::MatZZ)
    @boundscheck begin
        ncols(A) == nrows(B) || throw(DimensionMismatch("A cols must equal B rows"))
        nrows(C) == nrows(A) || throw(DimensionMismatch("C rows must equal A rows"))
        ncols(C) == ncols(B) || throw(DimensionMismatch("C cols must equal B cols"))
    end

    for i in 1:nrows(A)
        for j in 1:ncols(B)
            acc = ZZ(0)
            for k in 1:ncols(A)
                acc = acc + A[i, k] * B[k, j]
            end
            C[i, j] = acc
        end
    end
    return C
end

# Display in NTL format (row per line)
function Base.show(io::IO, m::MatZZ)
    r, c = size(m)
    if r == 0 || c == 0
        print(io, "[]")
        return
    end
    print(io, "[")
    for i in 1:r
        print(io, "[")
        for j in 1:c
            if j > 1
                print(io, " ")
            end
            print(io, m[i, j])
        end
        print(io, "]")
        if i < r
            print(io, "\n")
        end
    end
    print(io, "]")
end

# Similar for broadcasting
Base.similar(m::MatZZ) = MatZZ(nrows(m), ncols(m))
Base.similar(m::MatZZ, ::Type{ZZ}) = MatZZ(nrows(m), ncols(m))
Base.similar(m::MatZZ, dims::Dims{2}) = MatZZ(dims[1], dims[2])

# eltype
Base.eltype(::Type{MatZZ}) = ZZ
