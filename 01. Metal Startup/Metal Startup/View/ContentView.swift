//
//  ContentView.swift
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.self) private var environment
    @EnvironmentObject private var renderer: Renderer
    @State private var backgroundColor: Color = .black
    
    var body: some View {
        HStack (spacing: 0) {
            VStack {
                ColorPicker(selection: $backgroundColor, label: {
                    Text("Background Color")
                })
                Spacer()
                HStack {
                    Text(String(format: "%6.2f FPS", renderer.fps)).font(.caption.monospaced())
                    Text("\(Int(renderer.resolution.width)) X \(Int(renderer.resolution.height))").font(.caption)
                }
            }.padding()
            MetalView()
        }
        .onChange(of: backgroundColor) {
            renderer.backgroundColor = backgroundColor.resolve(in: environment)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Renderer())
}
