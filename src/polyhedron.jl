#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - pip_query                                                                             |
+==========================================================================================#

function pip_query(
    stl_model::STLInfo3D, 
    points   ::AbstractMatrix; 
    nsamples ::Int=3, 
    dev      ::String="CPU:0"
)
    # inputs check for points
    n, m = size(points)
    n == 3 || error("points must be a 3xN array")
    m >= 1 || error("at least 1 points are required")
    py_points = np.array(points')

    # query by using open3d
    vertices = stl_model.py_vertices
    faces = stl_model.py_triangles
    _dev = o3d.core.Device(dev)
    verts_o3d = o3d.core.Tensor(vertices, dtype=o3d.core.Dtype.Float32, device=_dev)
    faces_o3d = o3d.core.Tensor(faces, dtype=o3d.core.Dtype.Int32, device=_dev)
    mesh_t = o3d.t.geometry.TriangleMesh(_dev)
    mesh_t.vertex.positions = verts_o3d
    mesh_t.triangle.indices = faces_o3d
    scene = o3d.t.geometry.RaycastingScene(device=_dev)
    _ = scene.add_triangles(mesh_t)
    pts_t = o3d.core.Tensor(py_points.astype(np.float32), device=_dev)
    occ = scene.compute_occupancy(pts_t, nsamples=nsamples)
    tmp = occ.numpy().astype(pybuiltins.bool)
    
    return PyArray(tmp, copy=false)
end