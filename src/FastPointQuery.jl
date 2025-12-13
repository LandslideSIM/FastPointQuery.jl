module FastPointQuery

using CondaPkg, PythonCall
using DelimitedFiles, Downloads, PrecompileTools

# Python packages
const py_np         = PythonCall.pynew()
const py_shapely    = PythonCall.pynew()
const py_o3d        = PythonCall.pynew()
const py_rasterio   = PythonCall.pynew()
const py_json       = PythonCall.pynew()
const py_splashsurf = PythonCall.pynew()
const py_meshio     = PythonCall.pynew()

# PythonCall functions
const py2ju = PythonCall.pyconvert
const pyfun = PythonCall.pybuiltins

# resource
const res_dir = joinpath(@__DIR__, "../example")

function __init__()
    try # import Python modules
        PythonCall.pycopy!(py_np        , PythonCall.pyimport("numpy"       ))
        PythonCall.pycopy!(py_shapely   , PythonCall.pyimport("shapely"     ))
        PythonCall.pycopy!(py_o3d       , PythonCall.pyimport("open3d"      ))
        PythonCall.pycopy!(py_rasterio  , PythonCall.pyimport("rasterio"    ))
        PythonCall.pycopy!(py_json      , PythonCall.pyimport("json"        ))
        PythonCall.pycopy!(py_splashsurf, PythonCall.pyimport("pysplashsurf"))
        PythonCall.pycopy!(py_meshio    , PythonCall.pyimport("meshio"      ))
    catch e
        @error "Failed to initialize Python ENV" exception=e
    end
end

function pypkg_version()
    println("\n=== Python Library Versions ===")
    println("numpy:        ", py_np.__version__)
    println("shapely:      ", py_shapely.__version__)
    println("open3d:       ", py_o3d.__version__)
    println("rasterio:     ", py_rasterio.__version__)
    println("splashsurf:   ", pyhasattr(py_splashsurf, "__version__") ? py_splashsurf.__version__ : "N/A")
    println("meshio:       ", py_meshio.__version__)
    println("================================\n")
end

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