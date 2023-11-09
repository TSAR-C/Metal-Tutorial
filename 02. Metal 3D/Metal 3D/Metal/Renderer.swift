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
    private var uniformBuffer: MTLBuffer?
    
    var rgbTriangle: RGBTriangle!
    var axes: Axes!
    var camera: Camera!
    var controller: FPSController!
    
    var uniform: Uniform = Uniform(view: .init(1), projection: .init(1))
    
    func initWithView(_ view: MTKView) {
        view.delegate = self
        view.device = device
        
        if let device {
            RGBTriangle.initType(device)
            rgbTriangle = RGBTriangle(device)
            
            Axes.initType(device)
            axes = Axes(device)
        }
        
        camera = Camera()
        controller = FPSController(camera: camera)
        camera.position = SIMD3<Float>(0, -2, 1)
        camera.pitch = -20
        
        self.commandQueue = device?.makeCommandQueue()
        
        self.uniformBuffer = device?.makeBuffer(length: MemoryLayout<Uniform>.size)
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        let defaultLibrary = device?.makeDefaultLibrary()
        renderPipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = MemoryLayout<Vertex>.offset(of: \.position)!
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Vertex>.offset(of: \.color)!
        
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        self.renderPipelineState = try? device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspectRatio = Float(size.width / size.height)
        self.resolution = size
    }
    
    func draw(in view: MTKView) {
        let currentFrameTimestamp = Date.now
        let timeInterval = currentFrameTimestamp.timeIntervalSince(lastFrameTimestamp)
        lastFrameTimestamp = currentFrameTimestamp
        fps = 1.0 / timeInterval
        
        controller.update(Float(timeInterval))
        
        if let backgroundColor {
            view.clearColor = MTLClearColor(
                red: Double(backgroundColor.red),
                green: Double(backgroundColor.green),
                blue: Double(backgroundColor.blue),
                alpha: Double(backgroundColor.opacity))
        }
        
        uniform.projection = camera.projection
        uniform.view = camera.view
        
        self.uniformBuffer?.contents().storeBytes(of: uniform.view, toByteOffset: MemoryLayout<Uniform>.offset(of: \.view)!, as: simd_float4x4.self)
        self.uniformBuffer?.contents().storeBytes(of: uniform.projection, toByteOffset: MemoryLayout<Uniform>.offset(of: \.projection)!, as: simd_float4x4.self)
        
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState!)
        renderCommandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        
        rgbTriangle.draw(renderCommandEncoder)
        axes.draw(renderCommandEncoder)
        
        renderCommandEncoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
