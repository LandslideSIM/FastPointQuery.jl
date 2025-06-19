using FastPointQuery
using WGLMakie

stl_path1 = get_resource().dragon_phoenix
stl_path2 = get_resource().wheel

points = rand(3, 10000)
stl_model1 = readSTL3D(stl_path1)
stl_model2 = readSTL3D(stl_path2)

pip_query(stl_model1, points; nsamples=3, dev="CPU:0")
pip_query(stl_model2, points; nsamples=5)