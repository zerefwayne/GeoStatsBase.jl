# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

mean(d, v::Symbol, w::WeightingMethod) = mean(d[v], weight(d, w))
mean(d, v::Symbol, s::Number) = mean(d, v, BlockWeighting(ntuple(i->s,ncoords(d))))
mean(d, v::Symbol) = mean(d, v, median_heuristic(d))
mean(d, w::WeightingMethod) = Dict(v => mean(d, v, w) for v in name.(variables(d)))
mean(d, s::Number) = mean(d, BlockWeighting(ntuple(i->s,ncoords(d))))

"""
    mean(sdata)
    mean(sdata, v)
    mean(sdata, v, s)

Spatial mean of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
mean(d::AbstractData) = mean(d, median_heuristic(d))

var(d, v::Symbol, w::WeightingMethod) = var(d[v], weight(d, w), mean=mean(d, v, w), corrected=false)
var(d, v::Symbol, s::Number) = var(d, v, BlockWeighting(ntuple(i->s,ncoords(d))))
var(d, v::Symbol) = var(d, v, median_heuristic(d))
var(d, w::WeightingMethod) = Dict(v => var(d, v, w) for v in name.(variables(d)))
var(d, s::Number) = var(d, BlockWeighting(ntuple(i->s,ncoords(d))))

"""
    var(sdata)
    var(sdata, v)
    var(sdata, v, s)

Spatial variance of spatial data `sdata`. Optionally,
specify the variable `v` and the block side `s`.
"""
var(d::AbstractData) = var(d, median_heuristic(d))

quantile(d, v::Symbol, p, w::WeightingMethod) = quantile(d[v], weight(d, w), p)
quantile(d, v::Symbol, p, s::Number) = quantile(d, v, p, BlockWeighting(ntuple(i->s,ncoords(d))))
quantile(d, v::Symbol, p) = quantile(d, v, p, median_heuristic(d))
quantile(d, p, w::WeightingMethod) = Dict(v => quantile(d, v, p, w) for v in name.(variables(d)))
quantile(d, p::T, s::Number) where {T<:Union{Number,AbstractVector}} = quantile(d, p, BlockWeighting(ntuple(i->s,ncoords(d))))

"""
    quantile(sdata, p)
    quantile(sdata, v, p)
    quantile(sdata, v, p, s)

Spatial quantile of spatial data `sdata` at probability `p`.
Optionally, specify the variable `v` and the block side `s`.
"""
quantile(d::AbstractData, p) = quantile(d, p, median_heuristic(d))

function median_heuristic(d)
  # select at most 1000 points at random
  nel = nelms(d)
  inds = sample(1:nel, min(nel, 1000), replace=false)
  X = coordinates(d, inds)
  D = pairwise(Euclidean(), X, dims=2)

  # median heuristic
  n = size(D, 1)
  m = median(D[i,j] for i in 1:n for j in 1:n if i > j)

  # bounding box constraint
  l = minimum(sides(boundbox(d)))

  min(m, l)
end
