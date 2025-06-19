#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - get_pts                                                                               |
+==========================================================================================#

export get_pts

"""
    get_pts(polygon::QueryPolygon, h::Real; fill::Bool=true)

Description:
---
Get points inside a polygon at a specified grid resolution `h`. The input `polygon` is an
instance of `QueryPolygon`, and `h` is the grid resolution. If `fill` is set to true, it 
returns the points in a filled grid pattern; otherwise, it returns the center points of the 
grid cells.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
pts = get_pts(poly, 0.1; fill=true) # returns points in a filled grid pattern
```
"""
function get_pts(polygon::QueryPolygon, h::Real; fill::Bool=true)
    h > 0 || error("h must be positive")
    pypoly = polygon.polygon
    minx, miny, maxx, maxy = pypoly.bounds
    width = pyfun.int(np.ceil((maxx - minx) / h))
    height = pyfun.int(np.ceil((maxy - miny) / h))
    transform = rasterio.transform.from_origin(minx, maxy, h, h)
    mask = rasterize(
        [(pypoly, 1)],
        out_shape=(height, width),
        transform=transform,
        fill=0,
        dtype=np.uint8
    )
    rows, cols = np.where(mask == 1)
    xs, ys = rasterio.transform.xy(transform, rows, cols, offset="center")
    pts_cen = np.column_stack([xs, ys])
    if fill
        dx = dy = h / 4
        ul = pts_cen + np.array([-dx,  dy])
        ur = pts_cen + np.array([ dx,  dy])
        dl = pts_cen + np.array([-dx, -dy])
        dr = pts_cen + np.array([ dx, -dy])
        return PythonCall.PyArray(np.vstack([ul, ur, dl, dr]).T, copy=false)
    else
        return PythonCall.PyArray(pts_cen.T, copy=false)
    end
end

"""
    get_pts(stl_data::STLInfo2D, h::Real; fill::Bool=true)

Description:
---
Get points inside a 2D STL model at a specified grid resolution `h`. The input `stl_data` is 
an instance of `STLInfo2D`, which contains the mesh, vertices, and triangles of the STL 
model. If `fill` is set to true, it returns the points in a filled grid pattern; otherwise, 
it returns the center points of the grid cells.

Example:
---
```julia
stl_data = readSTL2D("path/to/your/file.stl")
pts = get_pts(stl_data, 0.1; fill=true) # returns points in a filled grid pattern
```
"""
function get_pts(stl_data::STLInfo2D, h::Real; fill::Bool=true)
    h > 0 || error("h must be positive")
    triangle_coords_2d = stl_data.py_vertices[stl_data.py_triangles]
    tris2d = shapely.polygons(triangle_coords_2d)
    region = shapely.unary_union(tris2d)
    polygon = QueryPolygon(region)
    return get_pts(polygon, h; fill=fill)
end