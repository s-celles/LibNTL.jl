"""
Development mode implementation for MatGF2 (matrices over GF(2)) using BitMatrix.
"""

"""
    MatGF2

Matrix over GF(2). Uses BitMatrix for efficient storage.
"""
mutable struct MatGF2 <: AbstractMat{GF2}
    data::BitMatrix
    MatGF2(m::BitMatrix) = new(m)
end

# Constructors
MatGF2() = MatGF2(falses(0, 0))
MatGF2(rows::Integer, cols::Integer) = MatGF2(falses(rows, cols))
MatGF2(m::Matrix{<:Integer}) = MatGF2(BitMatrix([isodd(x) for x in m]))
MatGF2(m::Matrix{GF2}) = MatGF2(BitMatrix([x.value for x in m]))
MatGF2(m::Matrix{Bool}) = MatGF2(BitMatrix(m))

# Size
Base.size(m::MatGF2) = size(m.data)
Base.size(m::MatGF2, d::Integer) = size(m.data, d)
nrows(m::MatGF2) = size(m, 1)
ncols(m::MatGF2) = size(m, 2)

# Indexing
function Base.getindex(m::MatGF2, i::Int, j::Int)
    @boundscheck checkbounds(m.data, i, j)
    return GF2(m.data[i, j])
end

function Base.setindex!(m::MatGF2, x::GF2, i::Int, j::Int)
    @boundscheck checkbounds(m.data, i, j)
    m.data[i, j] = x.value
    return m
end

Base.setindex!(m::MatGF2, x::Integer, i::Int, j::Int) = setindex!(m, GF2(x), i, j)
Base.setindex!(m::MatGF2, x::Bool, i::Int, j::Int) = setindex!(m, GF2(x), i, j)

# Copy
Base.copy(m::MatGF2) = MatGF2(copy(m.data))
Base.deepcopy_internal(m::MatGF2, dict::IdDict) = copy(m)

# Equality
Base.:(==)(m1::MatGF2, m2::MatGF2) = m1.data == m2.data

# Display
function Base.show(io::IO, m::MatGF2)
    print(io, "[")
    for i in 1:nrows(m)
        if i > 1
            print(io, "\n ")
        end
        print(io, "[")
        for j in 1:ncols(m)
            if j > 1
                print(io, " ")
            end
            print(io, Int(m.data[i, j]))
        end
        print(io, "]")
    end
    print(io, "]")
end

# Matrix arithmetic
function Base.:+(m1::MatGF2, m2::MatGF2)
    @assert size(m1) == size(m2) "Matrix dimensions must match"
    return MatGF2(xor.(m1.data, m2.data))
end

Base.:-(m1::MatGF2, m2::MatGF2) = m1 + m2  # Same as addition in GF(2)
Base.:-(m::MatGF2) = copy(m)  # Negation is identity

# Matrix multiplication
function Base.:*(m1::MatGF2, m2::MatGF2)
    @assert ncols(m1) == nrows(m2) "Matrix dimensions incompatible for multiplication"
    result = MatGF2(nrows(m1), ncols(m2))
    for i in 1:nrows(m1)
        for j in 1:ncols(m2)
            val = false
            for k in 1:ncols(m1)
                if m1.data[i, k] && m2.data[k, j]
                    val = xor(val, true)
                end
            end
            result.data[i, j] = val
        end
    end
    return result
end

# Matrix-vector multiplication
function Base.:*(m::MatGF2, v::VecGF2)
    @assert ncols(m) == length(v) "Dimensions incompatible"
    result = VecGF2(nrows(m))
    for i in 1:nrows(m)
        val = false
        for j in 1:ncols(m)
            if m.data[i, j] && v.data[j]
                val = xor(val, true)
            end
        end
        result.data[i] = val
    end
    return result
end

"""
    gauss!(m::MatGF2) -> Int

Perform Gaussian elimination on m in-place.
Returns the rank of the matrix.
"""
function gauss!(m::MatGF2)
    rows = nrows(m)
    cols = ncols(m)
    r = 0
    pivot_row = 1

    for col in 1:cols
        # Find pivot
        pivot_found = false
        for row in pivot_row:rows
            if m.data[row, col]
                # Swap rows if needed
                if row != pivot_row
                    for j in 1:cols
                        m.data[row, j], m.data[pivot_row, j] = m.data[pivot_row, j], m.data[row, j]
                    end
                end
                pivot_found = true
                break
            end
        end

        if !pivot_found
            continue
        end

        r += 1

        # Eliminate below (and above for reduced row echelon form)
        for row in 1:rows
            if row != pivot_row && m.data[row, col]
                for j in 1:cols
                    m.data[row, j] = xor(m.data[row, j], m.data[pivot_row, j])
                end
            end
        end

        pivot_row += 1
        if pivot_row > rows
            break
        end
    end

    return r
end

"""
    matrix_rank(m::MatGF2) -> Int

Compute the rank of a GF(2) matrix.
"""
function matrix_rank(m::MatGF2)
    m_copy = copy(m)
    return gauss!(m_copy)
end

# Transpose
function Base.transpose(m::MatGF2)
    return MatGF2(transpose(m.data))
end

# Identity matrix
function eye_gf2(n::Integer)
    m = MatGF2(n, n)
    for i in 1:n
        m.data[i, i] = true
    end
    return m
end
