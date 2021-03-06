# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NeighborhoodSearch(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
"""
struct NeighborhoodSearch{O,N,T} <: NeighborSearchMethod
  # input fields
  object::O
  neigh::N

  # state fields
  tree::T
end

function NeighborhoodSearch(object::O, neigh::N) where {O,N}
  tree = if neigh isa AbstractBallNeighborhood
    if metric(neigh) isa MinkowskiMetric
      KDTree(coordinates(object), metric(neigh))
    else
      BallTree(coordinates(object), metric(neigh))
    end
  else
    nothing
  end

  NeighborhoodSearch{O,N,typeof(tree)}(object, neigh, tree)
end

searchinds(xₒ, method::NeighborhoodSearch{O,N,T}) where {O,N<:BallNeighborhood,T} =
  inrange(method.tree, xₒ, radius(method.neigh))

searchinds(xₒ, method::NeighborhoodSearch{O,N,T}) where {O,N<:EllipsoidNeighborhood,T} =
  inrange(method.tree, xₒ, one(eltype(xₒ)))

# search method for any neighborhood
function search(xₒ::AbstractVector, method::NeighborhoodSearch; mask=nothing)
  object = method.object
  neigh  = method.neigh
  N = ncoords(object)
  T = coordtype(object)
  n = nelms(object)

  inds = mask ≠ nothing ? view(1:n, mask) : 1:n

  x = MVector{N,T}(undef)

  neighbors = Vector{Int}()
  @inbounds for ind in inds
    coordinates!(x, object, ind)
    if isneighbor(neigh, xₒ, x)
      push!(neighbors, ind)
    end
  end

  neighbors
end

# search method for ball neighborhood
function search(xₒ::AbstractVector, method::NeighborhoodSearch{O,N,T};
                mask=nothing) where {O,N<:AbstractBallNeighborhood,T}
  inds = searchinds(xₒ, method)

  if mask ≠ nothing
    neighbors = Vector{Int}()
    @inbounds for ind in inds
      if mask[ind]
        push!(neighbors, ind)
      end
    end
    neighbors
  else
    inds
  end
end
