#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
| struct:                                                                                  |  
| - STLInfo2D                                                                              |
| - STLInfo3D                                                                              |
+------------------------------------------------------------------------------------------+
| function:                                                                                |
|  - readSTL2D                                                                             |
|  - readSTL3D                                                                             |
+==========================================================================================#

export STLInfo2D, STLInfo3D
export readSTL2D, readSTL3D

struct STLInfo2D
    mesh        ::Py
    vmin        ::Vector
    vmax        ::Vector
    py_vertices ::Py
    py_triangles::Py
    stl_path    ::String
end

function Base.show(io::IO, info::STLInfo2D)
    println(io, "STLInfo2D:")
    println(io, "  Path     : ", info.stl_path)
    println(io, "  Vertices : ", info.py_vertices.shape[0])
    println(io, "  Triangles: ", info.py_triangles.shape[0])
    println(io, "  X-Y Min  : (", info.vmin[1], ", ", info.vmin[2], ")")
    println(io, "  X-Y Max  : (", info.vmax[1], ", ", info.vmax[2], ")")
end

struct STLInfo3D
    mesh        ::Py
    vmin        ::Vector
    vmax        ::Vector
    py_vertices ::Py
    py_triangles::Py
    stl_path    ::String
end

function Base.show(io::IO, info::STLInfo3D)
    println(io, "STLInfo3D:")
    println(io, "  Path     : ", info.stl_path)
    println(io, "  Vertices : ", info.py_vertices.shape[0])
    println(io, "  Triangles: ", info.py_triangles.shape[0])
    println(io, "  X-Y-Z Min: (", info.vmin[1], ", ", info.vmin[2], ", ", info.vmin[3], ")")
    println(io, "  X-Y-Z Max: (", info.vmax[1], ", ", info.vmax[2], ", ", info.vmax[3], ")")
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
    rows = pyslice(nothing, nothing, nothing)
    cols = pyslice(nothing, 2, nothing)
    vertices = np.asarray(mesh.vertices)[rows, cols]
    triangles = np.asarray(mesh.triangles)
    aabb = mesh.get_axis_aligned_bounding_box()
    vmin = py2ju(Vector, aabb.get_min_bound())[1:2]
    vmax = py2ju(Vector, aabb.get_max_bound())[1:2]
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
    vmin = py2ju(Vector, aabb.get_min_bound())
    vmax = py2ju(Vector, aabb.get_max_bound())
    return STLInfo3D(mesh, vmin, vmax, vertices, triangles, stl_file) 
end