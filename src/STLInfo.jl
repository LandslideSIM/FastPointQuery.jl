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

struct STLInfo
    mesh::Py
    vmin::Vector
    vmax::Vector
end

function loadmesh(stl_file)
    isfile(stl_file) || error("stl_file should be a valid file path")
    mesh = trimesh.load(stl_file, force="mesh")
    aabb_min, aabb_max = mesh.bounds
    vmin = pyconvert(Vector, aabb_min)
    vmax = pyconvert(Vector, aabb_max)
    return STLInfo(mesh, vmin, vmax) 
end