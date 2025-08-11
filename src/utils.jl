#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_polygon                                                                           |
|  - meshbuilder                                                                           |
|  - gridbuilder                                                                           |
|  - filling_pts                                                                           |
|  - get_normals                                                                           |
|  - sort_pts                                                                              |
+==========================================================================================#

export get_polygon
export meshbuilder
export gridbuilder
export filling_pts
export get_normals
export sort_pts

"""
    get_polygon(points::AbstractMatrix; ratio::Bool=0.1, allow_holes::Bool=false)

Description:
---
Get the polygon from the given points. `points` is a Nx2 array, and `ratio` is the
parameter for the concave hull. The default value is 0.1. `allow_holes` is a boolean
parameter to allow holes in the polygon.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1] # Nx2 array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
```
"""
function get_polygon(points::AbstractMatrix; ratio::Real=0.1, allow_holes::Bool=false)
    # inputs checking
    n, m = size(points)
    m == 2 || error("points must be a Nx2 array")
    n >= 3 || error("at least 3 points are required")
    ratio > 0 || error("ratio must be positive")
    # use shapely to get the polygon
    py_points = shapely.MultiPoint(np.array(points))
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
    result = Array{Float64, 2}(undef, nx * ny, 2)
    idx = 1
    @inbounds for i = 1:nx
        xi = x[i]
        @simd for j = 1:ny
            result[idx, 1] = xi
            result[idx, 2] = y[j]
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
    result = Array{Float64, 2}(undef, nx * ny * nz, 3)
    idx = 1
    @inbounds for k = 1:nz
        zk = z[k]
        for j = 1:nx
            xj = x[j]
            @simd for i = 1:ny
                result[idx, 1] = xj
                result[idx, 2] = y[i]
                result[idx, 3] = zk
                idx += 1
            end
        end
    end
    return result
end

function gridbuilder(xr::AbstractRange, yr::AbstractRange)
    T2 = Float64
    x, y = convert.(T2, xr), convert.(T2, yr)
    nx = length(x); nx ≤ 1 && error("Grid must have at least 2 points in x-direction")
    ny = length(y); ny ≤ 1 && error("Grid must have at least 2 points in y-direction")
    ni = nx * ny; nc = (nx - 1) * (ny - 1)
    _tmp_diff_vec_ = diff(x); all_equal = all(≈(_tmp_diff_vec_[1]), _tmp_diff_vec_)
    h1 = all_equal ? _tmp_diff_vec_[1] : error("grid spacing in x direction must be equal")
    _tmp_diff_vec_ = diff(y); all_equal = all(≈(_tmp_diff_vec_[1]), _tmp_diff_vec_)
    h2 = all_equal ? _tmp_diff_vec_[1] : error("grid spacing in y direction must be equal")
    h1 ≈ h2 || error("Grid spacing in x and y directions must be equal")
    h     = T2(h1)
    inv_h = T2(1 / h)
    x1    = T2(x[1])
    x2    = T2(x[end])
    y1    = T2(y[1])
    y2    = T2(y[end])
    ξ     = meshbuilder(x1:h:x2, y1:h:y2)
    return (nx=nx, ny=ny, ni=ni, nc=nc, h=h, x1=x[1], x2=x[end], y1=y[1], y2=y[end], inv_h=inv_h, ξ=ξ)
end

function gridbuilder(xr::AbstractRange, yr::AbstractRange, zr::AbstractRange)
    T2 = Float64
    x, y, z = convert.(Float64, xr), convert.(Float64, yr), convert.(Float64, zr)
    nx = length(x); nx ≤ 1 && error("Grid must have at least 2 points in x-direction")
    ny = length(y); ny ≤ 1 && error("Grid must have at least 2 points in y-direction")
    nz = length(z); nz ≤ 1 && error("Grid must have at least 2 points in z-direction")
    ni = nx * ny * nz; nc = (nx - 1) * (ny - 1) * (nz - 1)
    _tmp_diff_vec_ = diff(x); all_equal = all(≈(_tmp_diff_vec_[1]), _tmp_diff_vec_)
    h1 = all_equal ? _tmp_diff_vec_[1] : error("grid spacing in x direction must be equal")
    _tmp_diff_vec_ = diff(y); all_equal = all(≈(_tmp_diff_vec_[1]), _tmp_diff_vec_)
    h2 = all_equal ? _tmp_diff_vec_[1] : error("grid spacing in y direction must be equal")
    _tmp_diff_vec_ = diff(z); all_equal = all(≈(_tmp_diff_vec_[1]), _tmp_diff_vec_)
    h3 = all_equal ? _tmp_diff_vec_[1] : error("grid spacing in z direction must be equal")
    h1 ≈ h2 ≈ h3 || error("Grid spacing in x, y and z directions must be equal")
    h     = T2(h1)
    inv_h = T2(1 / h)
    x1    = T2(x[1])
    x2    = T2(x[end])
    y1    = T2(y[1])
    y2    = T2(y[end])
    z1    = T2(z[1])
    z2    = T2(z[end])
    ξ     = meshbuilder(x1:h:x2, y1:h:y2, z1:h:z2)
    return (nx=nx, ny=ny, nz=nz, ni=ni, nc=nc, h=h, x1=x1, x2=x2, y1=y1, y2=y2, z1=z1, 
        z2=z2, inv_h=inv_h, ξ=ξ)
end

"""
    filling_pts(pts_cen::AbstractMatrix{T}, h::Real) where T

Description:
---
Populate the points around the center points `pts_cen` with the spacing `h/4` (2/3D), which
is called "filling mode."
"""
@views function filling_pts(pts_cen::AbstractMatrix{T}, h::Real) where {T}
    # inputs checking
    h > 0 || error("h must be positive")
    N, D = size(pts_cen)              # N 行点，D=2或3 列坐标
    (D == 2 || D == 3) || throw(ArgumentError("pts_cen must have 2 or 3 columns (got $D)"))

    # offsets
    of3 = T[-1 -1 -1 -1 1 1 1 1; -1 -1 1 1 -1 -1 1 1; -1 1 -1 1 -1 1 -1 1]
    of2 = T[-1 -1  1  1; -1  1 -1  1]
    K = D == 3 ? 8 : 4
    offsets = D == 3 ? of3 : of2
    offsets .*= T(h * 0.25)

    # 输出为 (K*N) 行、D 列：每个中心点对应 K 行偏移点
    pts = Matrix{T}(undef, K * N, D)

    @inbounds for i in 1:N
        base = (i - 1) * K
        for j in 1:K
            @simd for d in 1:D
                pts[base + j, d] = pts_cen[i, d] + offsets[d, j]
            end
        end
    end
    return pts
end

"""
    get_normals(points::AbstractArray; k::Int=10)

Description:
---
Estimate normals for a set of points in 3D space using Open3D. The input `points` should be 
    a Nx3 array, where N is the number of points. The parameter `k` specifies the number of 
    nearest neighbors to use for normal estimation (default is 10).
"""
function get_normals(points::AbstractArray; k::Int=10)
    size(points, 2) == 3 || error("points must be a Nx3 array")
    pts = np.asarray(points, dtype=np.float64)
    o3d.utility.Vector3dVector(pts)
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(pts)
    pcd.estimate_normals(search_param=o3d.geometry.KDTreeSearchParamKNN(knn=k))
    pcd.orient_normals_to_align_with_direction([0, 0, 1])
    normals = PyArray(np.asarray(pcd.normals))
    return normals
end

"""
    sort_pts(pts::AbstractMatrix; xy::Bool=true)

Description:
---
If `xy` is true, sort the points in `pts` by the y-, and then x-coordinates (2/3D). 
If `xy` is false, sort the points by the z-, y-, and then x-coordinates (3D).
"""
function sort_pts(pts::AbstractMatrix; xy::Bool=true)
    if size(pts, 2) == 2 || xy
        perm = sortperm(axes(pts, 1), by = i -> (pts[i, 2], pts[i, 1]))
    elseif size(pts, 2) == 3🍻
        perm = sortperm(axes(pts, 1), by = i -> (pts[i, 2], pts[i, 1], pts[i, 3]))
    else
        throw(ArgumentError("The input points should have 2 or 3 rows (2/3D)"))
    end
    return Array(pts[perm, :])
end