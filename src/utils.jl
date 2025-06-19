#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_polygon                                                                           |
|  - meshbuilder                                                                           |
|  - populate_pts                                                                          |
+==========================================================================================#

export get_polygon
export meshbuilder
export populate_pts

"""
    get_polygon(points::AbstractMatrix; ratio::Bool=0.1, allow_holes::Bool=false)

Description:
---
Get the polygon from the given points. `points` is a 2xN array, and `ratio` is the
parameter for the concave hull. The default value is 0.1. `allow_holes` is a boolean
parameter to allow holes in the polygon.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
```
"""
function get_polygon(points::AbstractMatrix; ratio::Real=0.1, allow_holes::Bool=false)
    # inputs checking
    n, m = size(points)
    n == 2 || error("points must be a 2xN array")
    m >= 3 || error("at least 3 points are required")
    ratio > 0 || error("ratio must be positive")
    # use shapely to get the polygon
    py_points = shapely.MultiPoint(np.array(points'))
    poly = shapely.concave_hull(py_points, ratio=ratio, allow_holes=allow_holes)
    return QueryPolygon(poly)
end

"""
    meshbuilder(x::T, y::T; ϵ::String="FP64") where T <: AbstractRange

Description:
---
Generate structured mesh in 2D space.

Example:
---
```julia
x = 0:0.1:1
y = 0:0.1:1
mesh = meshbuilder(x, y; ϵ="FP32") # returns a 2xN array of points
``` 
"""
function meshbuilder(x::T, y::T; ϵ::String="FP64") where T <: AbstractRange
    x_tmp = repeat(x', length(y), 1) |> vec
    y_tmp = repeat(y , 1, length(x)) |> vec
    T1 = ϵ == "FP32" ? Float32 : Float64
    return Array{T1}(hcat(x_tmp, y_tmp)')
end

"""
    meshbuilder(x::T, y::T, z::T; ϵ::String="FP64") where T <: AbstractRange

Description:
---
Generate structured mesh in 3D space.

Example:
---
```julia
x = 0:0.1:1
y = 0:0.1:1
z = 0:0.1:1
mesh = meshbuilder(x, y, z; ϵ="FP32") # returns a 3xN array of points
"""
function meshbuilder(x::T, y::T, z::T; ϵ::String="FP64") where T <: AbstractRange
    vx      = x |> collect
    vy      = y |> collect
    vz      = z |> collect
    m, n, o = length(vy), length(vx), length(vz)
    vx      = reshape(vx, 1, n, 1)
    vy      = reshape(vy, m, 1, 1)
    vz      = reshape(vz, 1, 1, o)
    om      = ones(Int, m)
    on      = ones(Int, n)
    oo      = ones(Int, o)
    x_tmp   = vec(vx[om, :, oo])
    y_tmp   = vec(vy[:, on, oo])
    z_tmp   = vec(vz[om, on, :])
    T1 = ϵ == "FP32" ? Float32 : Float64
    return Array{T1}(hcat(x_tmp, y_tmp, z_tmp)')
end

"""
    populate_pts(pts_cen::AbstractMatrix{T}, h::Real) where T

Description:
---
Populate the points around the center points `pts_cen` with the spacing `h/4` (2/3D).
"""
@views function populate_pts(pts_cen::AbstractMatrix{T}, h::Real) where {T}
    h > 0 || error("h must be positive")
    D, N = size(pts_cen)
    (D == 2 || D == 3) ||
        throw(ArgumentError("pts_cen must have 2 or 3 rows (got $D)"))
    oft = T(h * 0.25)

    if D == 3
        offsets = oft .* [
            -1 -1 -1 -1  1  1  1  1;
            -1 -1  1  1 -1 -1  1  1;
            -1  1 -1  1 -1  1 -1  1
        ]
        K = 8
    else
        offsets = oft .* [
            -1 -1  1  1;
            -1  1 -1  1
        ]
        K = 4
    end

    pts = Matrix{T}(undef, D, K*N)
    @inbounds for i in 1:N
        base = (i-1)*K
        cen  = pts_cen[:, i]        # 取第 i 个中心点 (D×1)
        @simd for j in 1:K
            pts[:, base+j] .= cen .+ offsets[:, j]
        end
    end

    return pts
end