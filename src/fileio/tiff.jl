#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - readtiff                                                                              |
+==========================================================================================#

export readtiff

"""
    readtiff(filename::String, dst_crs::String="EPSG:3857")

Description:
---
Reads a GeoTIFF file and returns the pixel coordinates and values as a 3D array
with shape (N, 3), where N is the number of pixels. `dst_crs` specifies the destination 
coordinate reference system (CRS) for the output coordinates. The default CRS is "EPSG:3857" 
(Web Mercator).

Example:
---
```julia
xyz = readtiff("example.tiff")
#or
xyz = readtiff("example.tif")
```
"""
function readtiff(filename::String; dst_crs::String="EPSG:3857")
    isfile(filename) || throw(ArgumentError("file not found: $filename"))
    (endswith(filename, ".tiff") || endswith(filename, ".tif")) || error(
        "filename must be a .tif or .tiff file")

    @pyexec """
    def py_tmp(tif_path, dst_crs, rasterio, np):
        with rasterio.open(tif_path) as src:
            transform, width, height = rasterio.warp.calculate_default_transform(
                src.crs, dst_crs, src.width, src.height, *src.bounds)
            kwargs = src.meta.copy()
            kwargs.update({
                'crs': dst_crs,
                'transform': transform,
                'width': width,
                'height': height
            })
            data = np.empty((height, width), dtype=src.dtypes[0])
            rasterio.warp.reproject(
                source=rasterio.band(src, 1),
                destination=data,
                src_transform=src.transform,
                src_crs=src.crs,
                dst_transform=transform,
                dst_crs=dst_crs,
                resampling=rasterio.warp.Resampling.bilinear
            )
            nodata = kwargs.get('nodata', None)
            H, W = data.shape
            rows, cols = np.indices((H, W))
            rows = rows.ravel()
            cols = cols.ravel()
            zs = data.ravel().astype(np.float32)
            if nodata is not None:
                zs[zs == nodata] = np.nan
            xs, ys = rasterio.transform.xy(transform, rows, cols)
            xs = np.array(xs)
            ys = np.array(ys)
            xyz = np.column_stack([xs, ys, zs])
            return xyz
    """ => py_tmp

    return py2ju(Array, py_tmp(filename, dst_crs, rasterio, np))
end