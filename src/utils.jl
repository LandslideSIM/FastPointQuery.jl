#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_polygon                                                                           |
+==========================================================================================#

export get_polygon

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