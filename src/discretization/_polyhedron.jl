#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - _get_pts_voxel                                                                        |
|  - _get_pts_ray                                                                          |
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

function _get_pts_ray(stl_model::STLInfo3D, h::Real; fill::Bool=true, ϵ::String="FP32")
    points, pts2 = prepareprojection(stl_model, h, ϵ)
    println("\e[1;36m[start]:\e[0m generating pts at h = $h")
    edges = projectionlist(stl_model, points)
    pts_cen = fill_particles(edges, pts2, h)
    if fill
        return filling_pts(pts_cen, h)
    else
        return pts_cen
    end
end

function prepareprojection(stl_model::STLInfo3D, h::Real, ϵ)
    T = ϵ == "FP32" ? Float32 : Float64
    pts2 = meshbuilder(stl_model.vmin[1]-1.5h : h : stl_model.vmax[1]+1.5h,
                       stl_model.vmin[2]-1.5h : h : stl_model.vmax[2]+1.5h, ϵ=ϵ)
    vzlimit = T(stl_model.vmin[3] - 10h)
    points = vcat(pts2, vzlimit .* ones(T, 1, size(pts2, 2)))
    return points, pts2
end

function projectionlist(stl_model::STLInfo3D, points::AbstractArray{T}) where T
    # inputs check
    pts = points'; n, m = size(pts)
    m == 3 || error("points must be a 3xN array")

    mesh = stl_model.mesh
    pts = np.asarray(pts, dtype=np.float32)
    n_rays = pts.shape[0]
    scene = o3d.t.geometry.RaycastingScene()
    tmesh = o3d.t.geometry.TriangleMesh.from_legacy(mesh, vertex_dtype=o3d.core.float32)
    scene.add_triangles(tmesh)

    dirs = np.tile([0, 0, 1], (n_rays, 1))
    rays = o3d.core.Tensor(np.hstack((pts, dirs)), o3d.core.float32)
    hits = scene.list_intersections(rays)
    t_hit = hits["t_hit"].numpy()
    splits = hits["ray_splits"].numpy()

    t_chunks = np.split(t_hit, splits[1:-1])
    @pyexec """
    def py_tmp(pts, t_chunks, n_rays, splits, t_hit):
        z_chunks = [pts[i, 2] + t_hit[splits[i] : splits[i + 1]] for i in range(n_rays)]
        return z_chunks
    """ => py_tmp
    result = py_tmp(pts, t_chunks, n, splits, t_hit)
    return py2ju(Vector{Vector{T}}, result)
end

function fill_particles(edges::AbstractArray, pts::AbstractMatrix{T}, h::Real) where T
    x_all = Vector{T}(); sizehint!(x_all, 1024)
    y_all = Vector{T}(); sizehint!(y_all, 1024)
    z_all = Vector{T}(); sizehint!(z_all, 1024)
    @inbounds for i in eachindex(edges)
        v = edges[i]
        if !isempty(v) && iseven(length(v)) && any(!iszero, v)
            sort!(v); xi, yi = pts[1, i], pts[2, i]
            for j in 1:2:(length(v) - 1)
                for z in v[j]:h:v[j + 1]
                    push!(x_all, xi)
                    push!(y_all, yi)
                    push!(z_all, z)
                end
            end
        end
    end
    xyz = Matrix{T}(undef, 3, length(x_all))
    xyz[1, :] .= x_all
    xyz[2, :] .= y_all
    xyz[3, :] .= z_all
    return xyz
end