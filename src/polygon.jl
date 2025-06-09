#==========================================================================================++
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
| struct list:                                                                             |
|  - QueryPolygon                                                                          |
+------------------------------------------------------------------------------------------+
| function list:                                                                           |
|  - get_polygon (from LibGEOS, need to improve)                                           |
|  - pip_query                                                                             |
+==========================================================================================#

struct QueryPolygon
    ju_xy::AbstractMatrix
    py_xy::Py
    function QueryPolygon(ju_xy::AbstractMatrix, py_xy::Py)
        n, m = size(ju_xy)
        m >= 3 || error("at least 3 points are required")
        n == 2 || error("points must be 2D (2×N array)")
        new(ju_xy, py_xy)
    end
end

"""
    get_polygon(points::AbstractArray; ratio::Bool=0.1)

Description:
---
Get the polygon from the given points. `points` is a 2xN array, and `ratio` is the
parameter for the concave hull. The default value is 0.1.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
polygon = get_polygon(polygon_xy, ratio=1) # polygon.py_xy to visualize
```
"""
function get_polygon(points::AbstractArray; ratio::Real=0.1)
    # inputs checking
    n, m = size(points)
    n == 2 || error("points must be a 2xN array")
    m >= 3 || error("at least 3 points are required")
    ratio > 0 || error("ratio must be positive")
    # use shapely to get the polygon
    py_points = shapely.MultiPoint(np.array(points'))
    poly = shapely.concave_hull(py_points, ratio=ratio, allow_holes=false)
    xy = pyconvert(Array, np.array(poly.exterior.xy)) # get the exterior points of the polygon
    return QueryPolygon(xy, poly)
end

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
polygon = get_polygon(polygon_xy, ratio=1) # polygon.py_xy to visualize
pip_query(polygon, 0, 0) # check points (0, 0) and return false
pip_query(polygon, 0, 0, edge=true) # check points (0, 0) and return true
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
polygon = get_polygon(polygon_xy, ratio=1) # polygon.py_xy to visualize
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
        mask = shapely.covers(polygon.py_xy, py_points)
    else
        mask = shapely.within(py_points, polygon.py_xy)
    end

    return pyconvert(Vector{Bool}, mask)
end

"""
    pip_query(stl_file::String, points::AbstractMatrix; edge::Bool=false)

Description:
---
Determine whether a set of points is inside a 3D mesh defined by an STL file. The input
`stl_file` should be a valid file path to an STL file, and `points` should be a 2xN array
where each column represents a point (x, y). If `edge` is set to true, it checks if the 
points are on the edge of the mesh as well.

Example:
---
```julia
stl_file = "path/to/your/file.stl"
points = [0 0; 0.5 0.5; 1 1]'
pip_query(stl_file, points, edge=true)
```
"""
function pip_query(
    stl_file::String, 
    points  ::AbstractMatrix;
    edge    ::Bool=false
)
    isfile(stl_file) || error("stl_file must be a valid file path")
    size(points, 1) == 2 || error("points must be a 2xN array")
    py_points = shapely.points(points')
    if edge
        @pyexec """
        def py_pip(stl_file, py_points, trimesh, shapely):
            mesh = trimesh.load(stl_file, force="mesh")
            tris2d = mesh.triangles[:, :, :2]
            region = shapely.unary_union([shapely.Polygon(t) for t in tris2d])
            mask = shapely.covers(region, py_points)
            return mask
        """ => py_pip
    else
        @pyexec """
        def py_pip(stl_file, py_points, trimesh, shapely):
            mesh = trimesh.load(stl_file, force="mesh")
            tris2d = mesh.triangles[:, :, :2]
            region = shapely.unary_union([shapely.Polygon(t) for t in tris2d])
            mask = shapely.within(py_points, region)
            return mask
        """ => py_pip
    end
    tmp = py_pip(stl_file, py_points, trimesh, shapely)
    return pyconvert(Vector{Bool}, tmp)
end

"""
    pip_query(mesh::Py, points::AbstractMatrix; edge::Bool=false)

Description:
---
Determine whether a set of points is inside a 3D mesh defined by a Python object. The input 
`mesh` should be a Python object representing the mesh (`trimesh`), and `points` should be 
a 2xN array where each column represents a point (x, y). If `edge` is set to true, it checks 
if the points are on the edge of the mesh as well.

Example:
---
```julia
mesh = trimesh.load("path/to/your/file.stl", force="mesh")
points = [0 0; 0.5 0.5; 1 1]'
pip_query(mesh, points, edge=true)
```
"""
function pip_query(
    mesh    ::Py,
    points  ::AbstractMatrix;
    edge    ::Bool=false
)
    size(points, 1) == 2 || error("points must be a 2xN array")
    py_points = shapely.points(points')
    if edge
        @pyexec """
        def py_pip(mesh, py_points, trimesh, shapely):
            tris2d = mesh.triangles[:, :, :2]
            region = shapely.unary_union([shapely.Polygon(t) for t in tris2d])
            mask = shapely.covers(region, py_points)
            return mask
        """ => py_pip
    else
        @pyexec """
        def py_pip(mesh, py_points, trimesh, shapely):
            tris2d = mesh.triangles[:, :, :2]
            region = shapely.unary_union([shapely.Polygon(t) for t in tris2d])
            mask = shapely.within(py_points, region)
            return mask
        """ => py_pip
    end
    tmp = py_pip(mesh, py_points, trimesh, shapely)
    return pyconvert(Vector{Bool}, tmp)
end

"""
    pip_query(stl_model::STLInfo, points::AbstractMatrix; edge::Bool=false)

Description:
---
Determine whether a set of points is inside a 3D mesh defined by a 'STLInfo'. The input 
`stl_model` should be initiated by function `loadmesh(stl_file)`, and `points` should be 
a 2xN array where each column represents a point (x, y). If `edge` is set to true, it checks 
if the points are on the edge of the mesh as well.

Example:
---
```julia
stl_model = loadmesh("path/to/your/file.stl")
points = [0 0; 0.5 0.5; 1 1]'
pip_query(stl_model, points, edge=true)
```
"""
pip_query(stl_model::STLInfo, points::AbstractMatrix; edge::Bool=false) = pip_query(
    stl_model.mesh, points; edge=edge)