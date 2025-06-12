#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - readSTL2D                                                                             |
|  - readSTL3D                                                                             |
+==========================================================================================#

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