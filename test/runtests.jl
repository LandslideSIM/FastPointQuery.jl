using FastPointQuery
using CondaPkg
using PythonCall
using Test

@test !PythonCall.pyisnull(FastPointQuery.np        )
@test !PythonCall.pyisnull(FastPointQuery.shapely   )
@test !PythonCall.pyisnull(FastPointQuery.o3d       )
@test !PythonCall.pyisnull(FastPointQuery.trimesh   )
@test !PythonCall.pyisnull(FastPointQuery.rasterio  )
@test !PythonCall.pyisnull(FastPointQuery.rasterize )
@test !PythonCall.pyisnull(FastPointQuery.pyjson    )
@test !PythonCall.pyisnull(FastPointQuery.splashsurf)
@test !PythonCall.pyisnull(FastPointQuery.meshio    )

# Print versions of Python libraries
println("\n=== Python Library Versions ===")
println("numpy:        ", FastPointQuery.np.__version__)
println("shapely:      ", FastPointQuery.shapely.__version__)
println("open3d:       ", FastPointQuery.o3d.__version__)
println("trimesh:      ", FastPointQuery.trimesh.__version__)
println("rasterio:     ", FastPointQuery.rasterio.__version__)
println("rasterize:    ", pyhasattr(FastPointQuery.rasterize, "__version__") ? FastPointQuery.rasterize.__version__ : "N/A")
println("splashsurf:   ", pyhasattr(FastPointQuery.splashsurf, "__version__") ? FastPointQuery.splashsurf.__version__ : "N/A")
println("meshio:       ", FastPointQuery.meshio.__version__)
println("================================\n")

