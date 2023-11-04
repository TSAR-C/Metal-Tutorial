//
//  MetalView.swift
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    @EnvironmentObject private var renderer: Renderer
    
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        renderer.initWithView(view)
        return view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
    }
    
    typealias NSViewType = MTKView
}
