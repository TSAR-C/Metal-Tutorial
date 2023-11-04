//
//  Renderer.swift
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

import SwiftUI
import MetalKit

class Renderer: NSObject, MTKViewDelegate, ObservableObject {
    private let device = MTLCreateSystemDefaultDevice()
    private var commandQueue: MTLCommandQueue?
    
    var backgroundColor: Color.Resolved?
    
    private var lastFrameTimestamp = Date.now
    @Published var fps = 0.0
    var resolution = CGSize()
    
    private var renderPipelineState: MTLRenderPipelineState?
    private var buffer: MTLBuffer?
    private static let vertices: [Float] = [
        0.7, -0.7, 1, 0, 0, 1,
       -0.7, -0.7, 0, 1, 0, 1,
          0,  0.7, 0, 0, 1, 1
    ]
    
    func initWithView(_ view: MTKView) {
        view.delegate = self
        view.device = device
        
        self.commandQueue = device?.makeCommandQueue()
        
        self.buffer = device?.makeBuffer(bytes: Self.vertices, length: 4 * Self.vertices.count)
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        let defaultLibrary = device?.makeDefaultLibrary()
        renderPipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = 4 * 2
        
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = 4 * 6
        
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        self.renderPipelineState = try? device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.resolution = size
    }
    
    func draw(in view: MTKView) {
        let currentFrameTimestamp = Date.now
        let timeInterval = currentFrameTimestamp.timeIntervalSince(lastFrameTimestamp)
        lastFrameTimestamp = currentFrameTimestamp
        fps = 1.0 / timeInterval
        
        if let backgroundColor {
            view.clearColor = MTLClearColor(
                red: Double(backgroundColor.red),
                green: Double(backgroundColor.green),
                blue: Double(backgroundColor.blue),
                alpha: Double(backgroundColor.opacity))
        }
        
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderCommandEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderCommandEncoder.setRenderPipelineState(renderPipelineState!)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderCommandEncoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
