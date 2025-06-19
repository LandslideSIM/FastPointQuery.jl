using FastPointQuery
using WGLMakie

stl_model = readSTL3D(joinpath(@__DIR__, "wheel.stl"))

h = 3
pts = FastPointQuery._get_pts_ray(stl_model, h, ϵ="FP32")

saveply(joinpath(@__DIR__, "wheel.ply"), pts)

let
    fig = Figure()
    ax = LScene(fig[1, 1])
    scatter!(ax, pts, markersize=1)
    display(fig)
end
