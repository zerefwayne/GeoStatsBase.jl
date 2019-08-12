# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    NormalPointPartitioner(normal, point)

A method for partitioning spatial data into two half spaces
defined by a `normal` direction and a reference `point`.
"""
struct NormalPointPartitioner{T,N} <: AbstractPartitioner
  normal::SVector{N,T}
  point::SVector{N,T}
end

NormalPointPartitioner(normal::NTuple{N,T},
                  point::NTuple{N,T}=ntuple(i->zero(T), N)) where {T,N} =
  NormalPointPartitioner{T,N}(normalize(SVector(normal)), SVector(point))

function partition(object::AbstractSpatialObject{T,N},
                   partitioner::NormalPointPartitioner{T,N}) where {T,N}
  n = partitioner.normal
  p = partitioner.point

  x = MVector{N,T}(undef)

  left  = Vector{Int}()
  right = Vector{Int}()
  for location in 1:npoints(object)
    coordinates!(x, object, location)
    if (x - p) ⋅ n > zero(T)
      push!(left, location)
    else
      push!(right, location)
    end
  end

  SpatialPartition(object, [left,right])
end