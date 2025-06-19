module FastPointQuery

using CondaPkg, Downloads, PythonCall

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

# resource
const res_dir = joinpath(@__DIR__, "../example")

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

export get_resource, res_dir

function get_resource()
    @info "downloading resources..."
    url1 = "https://github.com/LandslideSIM/FastPointQuery.jl/releases/download/resource/dragon_phoenix.stl"
    url2 = "https://github.com/LandslideSIM/FastPointQuery.jl/releases/download/resource/wheel.stl"
    if !isfile(joinpath(res_dir, "dragon_phoenix.stl"))
        Downloads.download(url1, joinpath(res_dir, "dragon_phoenix.stl"))
    end
    if !isfile(joinpath(res_dir, "wheel.stl"))
        Downloads.download(url2, joinpath(res_dir, "wheel.stl"))
    end
    model = (dragon_phoenix = joinpath(res_dir, "dragon_phoenix.stl"),
             wheel          = joinpath(res_dir, "wheel.stl"))
    return model
end

end