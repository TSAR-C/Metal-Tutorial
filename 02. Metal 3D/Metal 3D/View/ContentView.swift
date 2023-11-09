//
//  ContentView.swift
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

import simd
import SwiftUI

struct ContentView: View {
    @Environment(\.self) private var environment
    @EnvironmentObject private var renderer: Renderer
    @State private var backgroundColor: Color = .black
    
    @State private var offsetX: Float = .zero
    @State private var offsetY: Float = .zero
    @State private var offsetZ: Float = .zero
    
    private var offset: SIMD3<Float> { SIMD3<Float>(offsetX, offsetY, offsetZ) }
    
    @State private var rotateAxisLatitude: Float = .zero
    @State private var rotateAxisLongitude: Float = .zero
    @State private var rotateAngle: Float = .zero
    
    private var rotation: simd_quatf {
        simd_quatf(angle: rotateAngle,
                   axis: SIMD3<Float>(
                        cos(rotateAxisLatitude) * cos(rotateAxisLongitude),
                        cos(rotateAxisLatitude) * sin(rotateAxisLongitude),
                        sin(rotateAxisLatitude)
                   )
        )
    }
    
    @State private var scaleX: Float = 1
    @State private var scaleY: Float = 1
    @State private var scaleZ: Float = 1
    
    private var scale: SIMD3<Float> {
        SIMD3<Float>(scaleX, scaleY, scaleZ)
    }
    
    var body: some View {
        HStack (spacing: 0) {
            VStack {
                ColorPicker(selection: $backgroundColor, label: {
                    Text("Background Color")
                })
                
                FloatPicker(value: $offsetX, range: -2...2, label: "X")
                FloatPicker(value: $offsetY, range: -2...2, label: "Y")
                FloatPicker(value: $offsetZ, range: -2...2, label: "Z")
                
                FloatPicker(value: $rotateAxisLatitude, range: -Float.pi/2...Float.pi/2, label: "LA")
                FloatPicker(value: $rotateAxisLongitude, range: -Float.pi...Float.pi, label: "LO")
                FloatPicker(value: $rotateAngle, range: -Float.pi...Float.pi, label: "AN")
                
                
                FloatPicker(value: $scaleX, range: -2...2, label: "SX")
                FloatPicker(value: $scaleY, range: -2...2, label: "SY")
                FloatPicker(value: $scaleZ, range: -2...2, label: "SZ")
                
                Spacer()
                HStack {
                    Text(String(format: "%6.2f FPS", renderer.fps)).font(.caption.monospaced())
                    Text("\(Int(renderer.resolution.width)) X \(Int(renderer.resolution.height))").font(.caption)
                }
            }.padding()
            MetalView()
                .focusable()
                .gesture(DragGesture(minimumDistance: .zero, coordinateSpace: .local)
                    .onChanged { _ in
                        renderer.controller.viewLock = false
                        renderer.controller.motionLock = false
                    }.onEnded { _ in
                        renderer.controller.viewLock = true
                        renderer.controller.motionLock = true
                    }
                )
                .onKeyPress(characters: ["w", "s", "a", "d", "e", "q"], phases: [.up, .down]) { event in
                    if let char = event.characters.first, let direction = FPSController.Direction(rawValue: char) {
                        if event.phase == .down {
                            renderer.controller.movingDirections.insert(direction)
                        } else if event.phase == .up {
                            renderer.controller.movingDirections.remove(direction)
                        }
                    }
                    return .handled
                }
                .padding()
        }
        .onChange(of: backgroundColor) {
            renderer.backgroundColor = backgroundColor.resolve(in: environment)
        }
        .onChange(of: offset) {
            renderer.rgbTriangle.translation = offset
        }
        .onChange(of: rotation) {
            renderer.rgbTriangle.rotation = rotation
        }
        .onChange(of: scale) {
            renderer.rgbTriangle.scaling = scale
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Renderer())
}
