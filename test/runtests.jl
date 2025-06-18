using FastPointQuery
using CondaPkg
using PythonCall
using Test

@test !PythonCall.pyisnull(FastPointQuery.np       )
@test !PythonCall.pyisnull(FastPointQuery.shapely  )
@test !PythonCall.pyisnull(FastPointQuery.o3d      )
@test !PythonCall.pyisnull(FastPointQuery.trimesh  )
@test !PythonCall.pyisnull(FastPointQuery.rasterio )
@test !PythonCall.pyisnull(FastPointQuery.rasterize)