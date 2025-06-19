#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - _get_pts_voxel                                                                        |
+==========================================================================================#

function _get_pts_voxel(stl_model::STLInfo3D, h::Real; fill::Bool=true)
    # inputs check
    h > 0 || error("h must be a positive number")
    step = h * 0.25
    offsets = np.array([-1  1  1; -1  1 -1; 1  1  1; 1  1 -1
                        -1 -1  1; -1 -1 -1; 1 -1  1; 1 -1 -1]) * step
    py_all = pyslice(nothing, nothing, nothing)

    # convert to trimesh
    vertices = stl_model.py_vertices
    faces = stl_model.py_triangles
    mesh_trimesh = trimesh.Trimesh(vertices=vertices, faces=faces, process=false)

    println("\e[1;36m[start]:\e[0m generating pts at h = $h")
    filled_vox = mesh_trimesh.voxelized(h).fill()
    pts_cen = filled_vox.points

    if fill # filling mode
        expanded = pts_cen[py_all, np.newaxis, py_all] + offsets[np.newaxis, py_all, py_all]
        return PyArray(expanded.reshape(-1, 3))
    else
        return PyArray(pts_cen)
    end
end