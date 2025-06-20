#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - _get_pts                                                                              |
+==========================================================================================#

function _get_pts(polygon::QueryPolygon, h::Real, fill::Bool, edge::Bool)
    h > 0 || error("h must be positive")
    pypoly = polygon.polygon
    minx, miny, maxx, maxy = pypoly.bounds
    width = pyfun.int(np.ceil((maxx - minx) / h))
    height = pyfun.int(np.ceil((maxy - miny) / h))
    transform = rasterio.transform.from_origin(minx, maxy, h, h)

    @info "generating pts at h = $h"
    mask = rasterize(
        [(pypoly, 1)],
        out_shape=(height, width),
        transform=transform,
        fill=0,
        dtype=np.uint8,
        all_touched=edge
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

function _get_pts(stl_data::STLInfo2D, h::Real, fill::Bool, edge::Bool)
    h > 0 || error("h must be positive")
    triangle_coords_2d = stl_data.py_vertices[stl_data.py_triangles]
    tris2d = shapely.polygons(triangle_coords_2d)
    region = shapely.unary_union(tris2d)
    polygon = QueryPolygon(region)
    return _get_pts(polygon, h, fill, edge)
end