#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_polygon                                                                           |
|  - read_polygon                                                                          |
|  - write_polygon                                                                         |
|  - readSTL2D                                                                             |
|  - readSTL3D                                                                             |
+==========================================================================================#

export get_polygon, read_polygon, write_polygon
export readSTL2D, readSTL3D


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
    write_polygon(polygon::QueryPolygon, file_path::String)

Description:
---
Write the polygon to a GeoJSON file. The `polygon` is an instance of `QueryPolygon`, and
`file_path` is the path where the GeoJSON file will be saved.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
write_polygon(poly, "/path/to/polygon.geojson")
# or
write_polygon(poly, "/path/to/polygon") # will automatically add .geojson
"""
function write_polygon(polygon::QueryPolygon, file_path::String)
    if !endswith(lowercase(file_path), ".geojson")
        file_path *= ".geojson"
    end
    @pyexec """
    def py_tmp(poly, filename, json, shapely):
        feature = {
            "type": "Feature",
            "geometry": shapely.geometry.mapping(poly),
            "properties": {}
        }
        geojson = {
            "type": "FeatureCollection",
            "features": [feature]
        }
        with open(filename, "w") as f:
            json.dump(geojson, f, indent=2)
    """ => py_tmp
    py_tmp(polygon.polygon, file_path, pyjson, shapely)
    @info """geojson file saved at:
    $file_path
    """
end

"""
    read_polygon(file_path::String)

Description:
---
Read a polygon from a GeoJSON file. The `file_path` is the path to the GeoJSON file.

Example:
---
```julia
polygon = read_polygon("/path/to/polygon.geojson")
```
"""
function read_polygon(file_path::String)
    isfile(file_path) || error("file_path should be a valid file path")
    endswith(lowercase(file_path), ".geojson") || error("file_path is not a .geojson file")
    @pyexec """
    def py_tmp(filename, json, shapely):
        with open(filename, "r") as f:
            data = json.load(f)
        feature = data["features"][0]
        geometry = feature["geometry"]
        polygon = shapely.geometry.shape(geometry)
        return polygon
    """ => py_tmp
    return QueryPolygon(py_tmp(file_path, pyjson, shapely))
end

"""
    readSTL2D(stl_file::String)

Description:
---
Read a STL file as a 2D object (z=0) containing the mesh, bounding box, vertices, and 
triangles.

Example:
---
```julia
stl_info = readSTL2D("path/to/your/file.stl")
```
"""
function readSTL2D(stl_file)
    isfile(stl_file) || error("stl_file should be a valid file path")
    mesh = o3d.io.read_triangle_mesh(stl_file)
    vertices = np.asarray(mesh.vertices)
    triangles = np.asarray(mesh.triangles)
    aabb = mesh.get_axis_aligned_bounding_box()
    vmin = pyconvert(Vector, aabb.get_min_bound())
    vmax = pyconvert(Vector, aabb.get_max_bound())
    return STLInfo2D(mesh, vmin, vmax, vertices, triangles, stl_file) 
end

"""
    readSTL3D(stl_file::String)

Description:
---
Read a STL file as a 3D object containing the mesh, bounding box, vertices, and triangles.

Example:
---
```julia
stl_info = readSTL3D("path/to/your/file.stl")
```
"""
function readSTL3D(stl_file)
    isfile(stl_file) || error("stl_file should be a valid file path")
    mesh = o3d.io.read_triangle_mesh(stl_file)
    vertices = np.asarray(mesh.vertices)
    triangles = np.asarray(mesh.triangles)
    aabb = mesh.get_axis_aligned_bounding_box()
    vmin = pyconvert(Vector, aabb.get_min_bound())
    vmax = pyconvert(Vector, aabb.get_max_bound())
    return STLInfo3D(mesh, vmin, vmax, vertices, triangles, stl_file) 
end