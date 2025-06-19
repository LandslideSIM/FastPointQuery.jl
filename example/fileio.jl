using FastPointQuery
using WGLMakie

points = rand(2, 100)
saveply(points, joinpath(@__DIR__, "pointcloud.ply"))
readply(joinpath(@__DIR__, "pointcloud.ply"), xy=true)

tiff_file = joinpath(@__DIR__, "akatani.tiff")

xyz = readtiff(tiff_file, dst_crs="+proj=tmerc +lat_0=0 +lon_0=136 +k=0.9999 +x_0=0 +y_0=0 +ellps=clrk66 +units=m +no_defs")#, dst_crs="EPSG:3099")
xyz1 = readtiff(tiff_file, dst_crs="EPSG:3099")
vmin = minimum(xyz, dims=2)
xyz[1, :] .-= vmin[1]
xyz[2, :] .-= vmin[2]
vmin1 = minimum(xyz1, dims=2)
xyz1[1, :] .-= vmin1[1]
xyz1[2, :] .-= vmin1[2]

let 
    fig = Figure()
    ax = LScene(fig[1, 1])
    surface!(ax, xyz1[1, :], xyz1[2, :], xyz1[3, :], colormap=:terrain)
    display(fig)
end

xyz = readasc(joinpath(@__DIR__, "dem1.asc"))
vmin = minimum(xyz, dims=2)
xyz[1, :] .-= vmin[1]
xyz[2, :] .-= vmin[2]

let 
    fig = Figure()
    ax = LScene(fig[1, 1])
    surface!(ax, xyz[1, :], xyz[2, :], xyz[3, :], colormap=:terrain)
    display(fig)
end