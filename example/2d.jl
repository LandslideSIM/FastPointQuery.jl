using FastPointQuery
using WGLMakie

points = rand(100, 2)
poly = get_polygon(points, ratio=0.1)
stl_file = joinpath(@__DIR__, "2d_hole.stl")
stl_model = readSTL2D(stl_file)

pip_query(poly, 0, 0.2)
pip_query(poly, points; edge=true)
pip_query(stl_model, points)

write_polygon(poly, joinpath(@__DIR__, "polygon.geojson"))
write_polygon(joinpath(@__DIR__, "polygon.geojson"), poly)
poly2 = read_polygon(joinpath(@__DIR__, "polygon.geojson"))

pts1 = FastPointQuery._get_pts(poly, 0.1, true, true)
pts2 = FastPointQuery._get_pts(poly, 0.1, false, false)
pts3 = FastPointQuery._get_pts(stl_model, 0.01, false, true)

let
    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    scatter!(ax, pts3)
    display(fig)
end