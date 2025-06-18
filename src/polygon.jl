#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - pip_query                                                                             |
+==========================================================================================#

include(joinpath(@__DIR__, "discretization/_polygon.jl"))

export pip_query

"""
    pip_query(polygon::QueryPolygon, px::Real, py::Real; edge::Bool=false)

Description:
---
Determine whether a point [px, py] is inside a polygon. Note to use the function 
`get_polygon` to get it; otherwise, it may lead to incorrect results. If the point is on the
edge of the polygon, you can set `edge=true` to check if it is considered as inside.

Example:
---
```julia
polypon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
pip_query(poly, 0, 0) # check points (0, 0) and return false
pip_query(poly, 0, 0, edge=true) # check points (0, 0) and return true
```
"""
function pip_query(
    polygon::QueryPolygon, 
    px     ::Real, 
    py     ::Real;
    edge   ::Bool=false
)
    func = edge ? shapely.intersects_xy : shapely.contains_xy
    return pyconvert(Bool, func(polygon.py_xy, px, py).item())
end

"""
    pip_query(polygon::QueryPolygon, points::AbstractMatrix; edge::Bool=false)

Description:
---
Determine whether a set of points is inside a polygon. The input `points` should be a 2xN
array, where each column represents a point (x, y). If `edge` is set to true, it checks if 
the points are on the edge of the polygon as well.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
pip_query(polygon, [0 0; 0.5 0.5; 1 1], edge=true) # returns [true, true, true]
```
"""
function pip_query(
    polygon::QueryPolygon, 
    points ::AbstractMatrix;
    edge   ::Bool=false
)
    # inputs check for points
    n, m = size(points)
    m ≥ 1 || error("points should have at least 1 point")
    n == 2 || error("points should be a 2xN array")
    py_points = shapely.points(points')
    
    # check if the particle is inside the polygon
    if edge
        mask = shapely.covers(polygon.polygon, py_points)
    else
        mask = shapely.within(py_points, polygon.polygon)
    end

    return pyconvert(Vector{Bool}, mask)
end

"""
    pip_query(stl_model::STLInfo2D, points::AbstractMatrix; edge::Bool=false)

Description:
---
Determine whether a set of points is inside a 3D mesh defined by a 'STLInfo'. The input 
`stl_model` should be initiated by function `readSTL2D(stl_file)`, and `points` should be 
a 2xN array where each column represents a point (x, y). If `edge` is set to true, it checks 
if the points are on the edge of the mesh as well.

Example:
---
```julia
stl_model = readSTL2D("path/to/your/file.stl")
points = [0 0; 0.5 0.5; 1 1]'
pip_query(stl_model, points, edge=true)
```
"""
function pip_query(
    stl_model::STLInfo2D,
    points   ::AbstractMatrix;
    edge     ::Bool=false
)
    size(points, 1) == 2 || error("points must be a 2xN array")
    py_points = shapely.points(points')
    if edge
        @pyexec """
        def py_pip(vertices, triangles, py_points, shapely):
            triangle_coords_2d = vertices[triangles][:, :, :2]
            tris2d = shapely.polygons(triangle_coords_2d)
            region = shapely.unary_union(tris2d)
            mask = shapely.covers(region, py_points)
            return mask
        """ => py_pip
    else
        @pyexec """
        def py_pip(vertices, triangles, py_points, shapely):
            triangle_coords_2d = vertices[triangles][:, :, :2]
            tris2d = shapely.polygons(triangle_coords_2d)
            region = shapely.unary_union(tris2d)
            mask = shapely.within(py_points, region)
            return mask
        """ => py_pip
    end
    tmp = py_pip(stl_model.py_vertices, stl_model.py_triangles, py_points, shapely)
    return pyconvert(Vector{Bool}, tmp)
end