module FastPointQuery

using CondaPkg, DelimitedFiles, Downloads, Logging, PrecompileTools, PythonCall

export pypkg_versions

# Python packages
const np         = PythonCall.pynew()
const shapely    = PythonCall.pynew()
const o3d        = PythonCall.pynew()
const trimesh    = PythonCall.pynew()
const rasterio   = PythonCall.pynew()
const pyjson     = PythonCall.pynew()
const splashsurf = PythonCall.pynew()
const meshio     = PythonCall.pynew()

# Python subpackages
const rasterize = PythonCall.pynew()

# PythonCall functions
const py2ju = PythonCall.pyconvert
const pyfun = PythonCall.pybuiltins

# resource
const res_dir = joinpath(@__DIR__, "../example")

function __init__()
    try # import Python modules
        PythonCall.pycopy!(np        , PythonCall.pyimport("numpy"       ))
        PythonCall.pycopy!(shapely   , PythonCall.pyimport("shapely"     ))
        PythonCall.pycopy!(o3d       , PythonCall.pyimport("open3d"      ))
        PythonCall.pycopy!(trimesh   , PythonCall.pyimport("trimesh"     ))
        PythonCall.pycopy!(rasterio  , PythonCall.pyimport("rasterio"    ))
        PythonCall.pycopy!(pyjson    , PythonCall.pyimport("json"        ))
        PythonCall.pycopy!(splashsurf, PythonCall.pyimport("pysplashsurf"))
        PythonCall.pycopy!(meshio    , PythonCall.pyimport("meshio"      ))
        # import submodules
        PythonCall.pycopy!(rasterize, pyimport("rasterio.features").rasterize)
    catch e
        @error "Failed to initialize Python ENV" exception=e
    end
end

function pypkg_versions()
    println("\n=== Python Library Versions ===")
    println("numpy:        ", np.__version__)
    println("shapely:      ", shapely.__version__)
    println("open3d:       ", o3d.__version__)
    println("trimesh:      ", trimesh.__version__)
    println("rasterio:     ", rasterio.__version__)
    println("splashsurf:   ", pyhasattr(splashsurf, "__version__") ? splashsurf.__version__ : "N/A")
    println("meshio:       ", meshio.__version__)
    println("================================\n")
end

include(joinpath(@__DIR__, "fileio/asc.jl"))
include(joinpath(@__DIR__, "fileio/geojson.jl"))
include(joinpath(@__DIR__, "fileio/ply.jl"))
include(joinpath(@__DIR__, "fileio/stl.jl"))
include(joinpath(@__DIR__, "fileio/tiff.jl"))
include(joinpath(@__DIR__, "fileio/xyz.jl"))

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

quiet(f) = redirect_stdout(devnull) do
    redirect_stderr(devnull) do
        with_logger(NullLogger()) do
            f()
        end
    end
end

#include(joinpath(@__DIR__, "precompile.jl"))

end