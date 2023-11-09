//
//  Geometry.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/9.
//

import simd

class Geometry {
    var translation: SIMD3<Float> = .zero
    var rotation: simd_quatf = .init(real: 1, imag: .zero)
    var scaling: SIMD3<Float> = .one
    
    var model: simd_float4x4 {
        var t = simd_float4x4(1)
        t[3] = SIMD4<Float>(translation, 1)
        
        let r = simd_float4x4(columns: (
            SIMD4<Float>(rotation.act(SIMD3<Float>(1, 0, 0)), 0),
            SIMD4<Float>(rotation.act(SIMD3<Float>(0, 1, 0)), 0),
            SIMD4<Float>(rotation.act(SIMD3<Float>(0, 0, 1)), 0),
            SIMD4<Float>(0, 0, 0, 1)))
            
        let s = simd_float4x4(diagonal: SIMD4<Float>(scaling, 1))
        
        return t * r * s
    }
}
