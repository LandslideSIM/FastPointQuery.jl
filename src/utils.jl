#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_polygon                                                                           |
|  - meshbuilder                                                                           |
|  - filling_pts                                                                           |
|  - get_normals                                                                           |
|  - sortpts                                                                               |
+==========================================================================================#

export get_polygon
export meshbuilder
export filling_pts
export get_normals
export sortpts

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
    meshbuilder(x::AbstractRange, y::AbstractRange)

Description:
---
Generate structured mesh in 2D space.

Example:
---
```julia
x = 0:0.1:1
y = 0:0.1:1
mesh = meshbuilder(x, y) # returns a 2xN array of points
``` 
"""
function meshbuilder(x::AbstractRange, y::AbstractRange)::Array{Float64, 2}
    nx, ny = length(x), length(y)
    result = Array{Float64, 2}(undef, 2, nx * ny)
    idx = 1
    @inbounds for i = 1:nx
        xi = x[i]
        @simd for j = 1:ny
            result[1, idx] = xi
            result[2, idx] = y[j]
            idx += 1
        end
    end
    return result
end

"""
    meshbuilder(x::AbstractRange, y::AbstractRange, z::AbstractRange)

Description:
---
Generate structured mesh in 3D space.

Example:
---
```julia
x = 0:0.1:1
y = 0:0.1:1
z = 0:0.1:1
mesh = meshbuilder(x, y, z) # returns a 3xN array of points
```
"""
function meshbuilder(x::AbstractRange, y::AbstractRange, z::AbstractRange)::Array{Float64, 2}
    nx, ny, nz = length(x), length(y), length(z)
    result = Array{Float64, 2}(undef, 3, nx * ny * nz)
    idx = 1
    @inbounds for k = 1:nz
        zk = z[k]
        for j = 1:nx
            xj = x[j]
            @simd for i = 1:ny
                result[1, idx] = xj
                result[2, idx] = y[i]
                result[3, idx] = zk
                idx += 1
            end
        end
    end
    return result
end

"""
    filling_pts(pts_cen::AbstractMatrix{T}, h::Real) where T

Description:
---
Populate the points around the center points `pts_cen` with the spacing `h/4` (2/3D), which
is called "filling mode."
"""
@views function filling_pts(pts_cen::AbstractMatrix{T}, h::Real) where T
    # inputs checking
    h > 0 || error("h must be positive")
    D, N = size(pts_cen)
    (D == 2 || D == 3) || throw(ArgumentError("pts_cen must have 2 or 3 rows (got $D)"))
    of1 = T[-1 -1 -1 -1 1 1 1 1; -1 -1 1 1 -1 -1 1 1; -1 1 -1 1 -1 1 -1 1]
    of2 = T[-1 -1 1 1; -1 1 -1 1]
    K = D == 3 ? 8 : 4
    offsets = D == 3 ? of1 : of2
    offsets .*= T(h * 0.25)
    # filling mode
    pts = Matrix{T}(undef, D, K*N)
    @inbounds for i in 1:N
        base, cen = (i - 1) * K, pts_cen[:, i] 
        @simd for j in 1:K
            pts[:, base+j] .= cen .+ offsets[:, j]
        end
    end
    return pts
end

function get_normals(points::AbstractArray; k::Int=10)
    size(points, 1) == 3 || error("points must be a 3xN array")
    pts = np.asarray(points, dtype=np.float64).T
    o3d.utility.Vector3dVector(pts)
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(pts)
    pcd.estimate_normals(search_param=o3d.geometry.KDTreeSearchParamKNN(knn=k))
    pcd.orient_normals_to_align_with_direction([0, 0, 1])
    normals = PyArray(np.asarray(pcd.normals).T)
    return normals
end

"""
    sortpts(pts::AbstractMatrix; xy::Bool=true)

Description:
---
If `xy` is true, sort the points in `pts` by the y-, and then x-coordinates (2/3D). 
If `xy` is false, sort the points by the z-, y-, and then x-coordinates (3D).
"""
function sortpts(pts::AbstractMatrix; xy::Bool=true)
    if size(pts, 1) == 2 || xy
        perm = sortperm(axes(pts, 2), by = i -> (pts[2, i], pts[1, i]))
    elseif size(pts, 1) == 3🍻
        perm = sortperm(axes(pts, 2), by = i -> (pts[2, i], pts[1, i], pts[3, i]))
    else
        throw(ArgumentError("The input points should have 2 or 3 rows (2/3D)"))
    end
    return Array(pts[:, perm])
end