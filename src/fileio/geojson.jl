#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
| struct:                                                                                  |
|  - QueryPolygon                                                                          |
+------------------------------------------------------------------------------------------+
| function:                                                                                |
|  - read_polygon                                                                          |
|  - write_polygon                                                                         |
+==========================================================================================#

export QueryPolygon
export read_polygon, write_polygon

struct QueryPolygon
    polygon::Py
    coord  ::AbstractVector
end

function QueryPolygon(pypoly::Py)
    @pyexec """
    def py_tmp(poly, np):
        rings = []
        exterior = np.array(poly.exterior.coords)
        rings.append(exterior)
        for interior in poly.interiors:
            hole = np.array(interior.coords)
            rings.append(hole)
        return rings
    """ => py_tmp
    coord = py2ju(Vector, py_tmp(pypoly, np))
    return QueryPolygon(pypoly, coord)
end

"""
    write_polygon(polygon::QueryPolygon, file_path::String)

Description:
---
Write the polygon to a GeoJSON file. The `polygon` is an instance of `QueryPolygon`, and
`file_path` is the path where the GeoJSON file will be saved.

Example:
---
```julia
polygon_xy = [0 0; 1 0; 1 1; 0 1]' # 2xN array
poly = get_polygon(polygon_xy, ratio=1) # poly.polygon to visualize
write_polygon(poly, "/path/to/polygon.geojson")
# or
write_polygon(poly, "/path/to/polygon") # will automatically add .geojson
"""
function write_polygon(polygon::QueryPolygon, file_path::String)
    if !endswith(lowercase(file_path), ".geojson")
        file_path *= ".geojson"
    end
    @pyexec """
    def py_tmp(poly, filename, json, shapely):
        feature = {
            "type": "Feature",
            "geometry": shapely.geometry.mapping(poly),
            "properties": {}
        }
        geojson = {
            "type": "FeatureCollection",
            "features": [feature]
        }
        with open(filename, "w") as f:
            json.dump(geojson, f, indent=2)
    """ => py_tmp
    py_tmp(polygon.polygon, file_path, pyjson, shapely)
    @info """geojson file saved at:
    $file_path
    """
end

write_polygon(file_path::String, polygon::QueryPolygon) = write_polygon(polygon, file_path)

"""
    read_polygon(file_path::String)

Description:
---
Read a polygon from a GeoJSON file. The `file_path` is the path to the GeoJSON file.

Example:
---
```julia
polygon = read_polygon("/path/to/polygon.geojson")
```
"""
function read_polygon(file_path::String)
    isfile(file_path) || error("file_path should be a valid file path")
    endswith(lowercase(file_path), ".geojson") || error("file_path is not a .geojson file")
    @pyexec """
    def py_tmp(filename, json, shapely):
        with open(filename, "r") as f:
            data = json.load(f)
        feature = data["features"][0]
        geometry = feature["geometry"]
        polygon = shapely.geometry.shape(geometry)
        return polygon
    """ => py_tmp
    return QueryPolygon(py_tmp(file_path, pyjson, shapely))
end