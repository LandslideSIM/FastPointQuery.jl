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

include(joinpath(@__DIR__, "fileio/geojson.jl"))
include(joinpath(@__DIR__, "fileio/stl.jl"))

include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "polygon.jl"))
include(joinpath(@__DIR__, "polyhedron.jl"))

# export structs
export QueryPolygon, STLInfo2D, STLInfo3D

end