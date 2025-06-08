using FastPointQuery
using PythonCall

trimesh = PythonCall.pyimport("trimesh")
shapely = PythonCall.pyimport("shapely")
np = PythonCall.pyimport("numpy")

stl_file = joinpath(@__DIR__, "../assets/test2d.stl")
points = rand(0:0.1:1, 2, 10)
rst = pip_query(stl_file, points, edge=true) # returns [true, true, true]
