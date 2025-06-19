using FastPointQuery

points = rand(2, 100)
saveply(points, joinpath(@__DIR__, "pointcloud.ply"))
readply(joinpath(@__DIR__, "pointcloud.ply"), xy=true)