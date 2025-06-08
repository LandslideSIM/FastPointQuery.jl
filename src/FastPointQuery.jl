module FastPointQuery

using CondaPkg, LibGEOS, Printf, PythonCall

const np      = PythonCall.pynew()
const shapely = PythonCall.pynew()
const o3d     = PythonCall.pynew()
const trimesh = PythonCall.pynew()

function __init__()
    @info "initializing environment..."
    try # import Python modules
        PythonCall.pycopy!(np     , PythonCall.pyimport("numpy"  ))
        PythonCall.pycopy!(shapely, PythonCall.pyimport("shapely"))
        PythonCall.pycopy!(o3d    , PythonCall.pyimport("open3d" ))
        PythonCall.pycopy!(trimesh, PythonCall.pyimport("trimesh"))
    catch e
        @error "Failed to initialize Python ENV" exception=e
    end
end

include(joinpath(@__DIR__, "polygon.jl"))

# export structs
export QueryPolygon
# export functions
export get_polygon, pip_query

end