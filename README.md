# ***FastPointQuery***

[![CI](https://github.com/LandslideSIM/FastPointQuery.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/LandslideSIM/FastPointQuery.jl/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-v0.4.0-pink)]()

> This is a dependency package for [MaterialPointGenerator.jl](https://github.com/LandslideSIM/MaterialPointGenerator.jl), for easier Python ENV management.

## Installation ⚙️

Just type <kbd>]</kbd> in Julia's  `REPL`:

```julia
julia> ]
(@1.11) Pkg> add FastPointQuery
```

Documentation:

```julia
help?>pip_query

help?>get_polygon
help?>write_polygon
help?>read_polygon

help?>readSTL2D
help?>readSTL3D
help?>readasc
help?>readtiff
help?>readply
help?>saveply
```

## Features ✨ 

- [x] point(s)-in-polygon
- [x] point(s)-in-polyhedron
- [x] read files (`.stl`, `.geojson`, `.ply`, `.tiff`, `.asc`)
- [x] write files (`.geojson`, `.ply`)

In addition, we have exposed the interfaces of `numpy`, `shapely`, `open3d`, `trimesh`, `scipy`, and `rasterio` through [PythonCall.jl](https://github.com/JuliaPy/PythonCall.jl) for convenient use in [MaterialPointGenerator.jl](https://github.com/LandslideSIM/MaterialPointGenerator.jl).

## Acknowledgement 👍

This project is sponserd by [Risk Group | Université de Lausanne](https://wp.unil.ch/risk/) and [China Scholarship Council [中国国家留学基金管理委员会]](https://www.csc.edu.cn/).