module FastPointQuery

using CondaPkg, PythonCall

const np       = PythonCall.pynew()
const shapely  = PythonCall.pynew()
const o3d      = PythonCall.pynew()
const trimesh  = PythonCall.pynew()
const rasterio = PythonCall.pynew()

const py2ju = PythonCall.pyconvert
const pyfun = PythonCall.pybuiltins

function __init__()
    @info "initializing environment..."
    try # import Python modules
        PythonCall.pycopy!(np      , PythonCall.pyimport("numpy"   ))
        PythonCall.pycopy!(shapely , PythonCall.pyimport("shapely" ))
        PythonCall.pycopy!(o3d     , PythonCall.pyimport("open3d"  ))
        PythonCall.pycopy!(trimesh , PythonCall.pyimport("trimesh" ))
        PythonCall.pycopy!(rasterio, PythonCall.pyimport("rasterio"))
    catch e
        @error "Failed to initialize Python ENV" exception=e
    end
end

struct STLInfo2D
    mesh        ::Py
    vmin        ::Vector
    vmax        ::Vector
    py_vertices ::Py
    py_triangles::Py
    stl_path    ::String
end

struct STLInfo3D
    mesh        ::Py
    vmin        ::Vector
    vmax        ::Vector
    py_vertices ::Py
    py_triangles::Py
    stl_path    ::String
end

struct QueryPolygon
    ju_xy::AbstractMatrix
    py_xy::Py
    function QueryPolygon(ju_xy::AbstractMatrix, py_xy::Py)
        n, m = size(ju_xy)
        m >= 3 || error("at least 3 points are required")
        n == 2 || error("points must be 2D (2×N array)")
        new(ju_xy, py_xy)
    end
end

include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "polygon.jl"))
include(joinpath(@__DIR__, "polyhedron.jl"))


# export structs
export QueryPolygon, STLInfo2D, STLInfo3D
# export functions
export get_polygon, pip_query, readSTL2D, readSTL3D

end