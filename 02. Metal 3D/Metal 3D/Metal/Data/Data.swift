//
//  Data.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/9.
//

import simd

struct Vertex {
    var position: SIMD3<Float>
    var color: SIMD4<Float>
}

struct Uniform {
    var view: simd_float4x4
    var projection: simd_float4x4
}
