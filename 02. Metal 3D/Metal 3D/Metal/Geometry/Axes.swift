//
//  Axes.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/9.
//

import simd
import Metal

class Axes: Geometry {
    private static let vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(0, 0, 0), color: SIMD4<Float>(1, 0, 0, 1)),
        Vertex(position: SIMD3<Float>(1, 0, 0), color: SIMD4<Float>(1, 0, 0, 1)),
        Vertex(position: SIMD3<Float>(0, 0, 0), color: SIMD4<Float>(0, 1, 0, 1)),
        Vertex(position: SIMD3<Float>(0, 1, 0), color: SIMD4<Float>(0, 1, 0, 1)),
        Vertex(position: SIMD3<Float>(0, 0, 0), color: SIMD4<Float>(0, 0, 1, 1)),
        Vertex(position: SIMD3<Float>(0, 0, 1), color: SIMD4<Float>(0, 0, 1, 1))
    ]
    
    private static var buffer: MTLBuffer!
    
    static func initType(_ device: MTLDevice) {
        buffer = device.makeBuffer(bytes: Self.vertices, length: Self.vertices.count * MemoryLayout<Vertex>.stride)
    }
    
    private var modelBuffer: MTLBuffer!
    
    init(_ device: MTLDevice) {
        super.init()
        scaling = .one * 10
        modelBuffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.size)
    }
    
    func draw(_ encoder: MTLRenderCommandEncoder) {
        modelBuffer.contents().storeBytes(of: super.model, toByteOffset: 0, as: simd_float4x4.self)
        
        encoder.setVertexBuffer(Self.buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(modelBuffer, offset: 0, index: 1)
        
        encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 6)
    }
}

