module FastPointQuery

using CondaPkg, PythonCall

# Python packages
const np       = PythonCall.pynew()
const shapely  = PythonCall.pynew()
const o3d      = PythonCall.pynew()
const trimesh  = PythonCall.pynew()
const rasterio = PythonCall.pynew()
const pyjson   = PythonCall.pynew()

# Python subpackages
const rasterize = PythonCall.pynew()

# PythonCall functions
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
        PythonCall.pycopy!(pyjson  , PythonCall.pyimport("json"    ))
        # import submodules
        PythonCall.pycopy!(rasterize, pyimport("rasterio.features").rasterize)
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
    polygon::Py
    coord  ::AbstractVector
end

function QueryPolygon(pypoly::Py)
    @pyexec """
    def py_tmp(poly, np):
        rings = []
        exterior = np.array(poly.exterior.coords)
        rings.append(exterior)
        for interior in poly.interiors:
            hole = np.array(interior.coords)
            rings.append(hole)
        return rings
    """ => py_tmp
    coord = py2ju(Vector, py_tmp(pypoly, np))
    return QueryPolygon(pypoly, coord)
end

include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "polygon.jl"))
include(joinpath(@__DIR__, "polyhedron.jl"))

# export structs
export QueryPolygon, STLInfo2D, STLInfo3D

end