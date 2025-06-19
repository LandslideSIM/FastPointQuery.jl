#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - saveply                                                                               |
|  - readply                                                                               |
+==========================================================================================#

export saveply, readply

"""
    saveply(points::AbstractArray, filename::String)

Description:
---
Saves a point cloud to a PLY file.

Example:
---
```julia
points = rand(3, 1000) # 3D points
saveply(points, "pointcloud.ply")
# or
saveply("pointcloud", points) # add .ply extension automatically

points = rand(2, 1000) # 2D points
saveply("pointcloud.ply", points)
```
"""
function saveply(points::AbstractArray, filename::String)
    # input check
    n, m = size(points)
    n in [2, 3] || throw(ArgumentError("points must be a 2D array with 2 or 3 rows"))
    if !endswith(filename, ".ply")
        filename *= ".ply"
    end
    if n == 2
        pts = vcat(points, zeros(1, m))'
    else
        pts = points'
    end

    cloud = trimesh.points.PointCloud(pts)
    cloud.export(filename)
    @info """point data saved at 
    $(filename)
    """
    return nothing
end

saveply(filename::String, points::AbstractArray) = saveply(points, filename)

"""
    readply(filename::String; xy::Bool=false)

Description:
---
Reads a point cloud from a PLY file. If `xy` is true, it returns only the 2D points (neglect z).

Example:
---
```julia
pc = readply("pointcloud.ply")
# or
pc = readply("pointcloud.ply", xy=true) # returns only x and y
"""
function readply(filename::String; xy::Bool=false)
    isfile(filename) || throw(ArgumentError("file $(filename) does not exist"))
    pc = py2ju(Array, trimesh.load(filename).vertices.T)
    if xy
        return Array(pc[1:2, :])
    else
        return pc
    end
end