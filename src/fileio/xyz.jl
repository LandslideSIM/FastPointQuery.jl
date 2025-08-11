#==========================================================================================+
| TABLE OF CONTENTS:                                                                       |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  - readxy                                                                                |
|  - readxyz                                                                               |
|  - savexy                                                                                |
|  - savexyz                                                                               |
+==========================================================================================#

export readxy
export readxyz
export savexy
export savexyz

"""
    readxy(file_dir::P) where P <: String

Description:
---
Read the 2D `.xy` file from `file_dir`.
"""
function readxy(file_dir::P) where P <: String
    xy = readdlm(file_dir, ' ')[:, 1:2]
    return Array{Float64}(xy)
end

"""
    readxyz(file_dir::P) where P <: String

Description:
---
Read the 3D `.xyz` file from `file_dir`.
"""
function readxyz(file_dir::P) where P <: String
    xyz = readdlm(file_dir, ' ')[:, 1:3]
    return Array{Float64}(xyz)
end

"""
    savexy(file_dir::P, pts::T) where {P <: String, T <: AbstractMatrix}

Description:
---
Save the 2D points `pts` to the `.xy` file (`file_dir`).
"""
function savexy(file_dir::P, pts::T) where {P <: String, T <: AbstractMatrix}
    size(pts, 2) == 2 || throw(ArgumentError("The input points should have 2 columns."))
    open(file_dir, "w") do io
        writedlm(io, pts, ' ')
    end
end
savexy(pts::T, file_dir::P) where {P <: String, T <: AbstractMatrix} = savexy(file_dir, pts)

"""
    savexyz(file_dir::P, pts::T) where {P <: String, T <: AbstractMatrix}

Description:
---
Save the 3D points `pts` to the `.xyz` file (`file_dir`).
"""
function savexyz(file_dir::P, pts::T) where {P <: String, T <: AbstractMatrix}
    size(pts, 2) == 3 || throw(ArgumentError("The input points should have 3 columns."))
    open(file_dir, "w") do io
        writedlm(io, pts, ' ')
    end
end
savexyz(pts::T, file_dir::P) where {P <: String, T <: AbstractMatrix} = savexyz(file_dir, pts)