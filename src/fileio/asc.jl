#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - readasc                                                                               |
+==========================================================================================#

export readasc

"""
    readasc(filename::String)

Description:
---
Reads an ASCII grid file (.asc) and returns the pixel coordinates and values as a 3D array
with shape (3, N), where N is the number of pixels.

Example:
---
```julia
xyz = readasc("example.asc")
```
"""
function readasc(filename::String)
    isfile(filename) || throw(ArgumentError("file not found: $filename"))
    endswith(filename, ".asc") || error("filename must be a .asc file")

    @pyexec """
    def py_tmp(asc_path, rasterio, np):
        with rasterio.open(asc_path) as src:
            band = src.read(1)
            transform = src.transform
            nodata = src.nodata
            H, W = band.shape

            # 获取像素索引网格
            rows, cols = np.indices((H, W))
            rows = rows.ravel()
            cols = cols.ravel()

            # 提取高程并处理 nodata 为 NaN
            zs = band.ravel().astype(np.float32)
            if nodata is not None:
                zs[zs == nodata] = np.nan

            # 转换像素坐标 → 实际地理坐标 (x, y)，单位与原始数据一致（可能是米或经纬度）
            xs, ys = rasterio.transform.xy(transform, rows, cols)
            xs = np.array(xs)
            ys = np.array(ys)

            # 拼成 (N, 3) 的数组
            xyz = np.column_stack([xs, ys, zs])
            return xyz.T
    """ => py_tmp
    
    return py2ju(Array, py_tmp(filename, rasterio, np))
end
