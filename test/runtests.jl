using FastPointQuery
using PythonCall
using Test

@test !PythonCall.pyisnull(FastPointQuery.py_np        )
@test !PythonCall.pyisnull(FastPointQuery.py_shapely   )
@test !PythonCall.pyisnull(FastPointQuery.py_o3d       )
@test !PythonCall.pyisnull(FastPointQuery.py_rasterio  )
@test !PythonCall.pyisnull(FastPointQuery.py_json      )
@test !PythonCall.pyisnull(FastPointQuery.py_splashsurf)
@test !PythonCall.pyisnull(FastPointQuery.py_meshio    )

# Print versions of Python libraries
FastPointQuery.pypkg_version()