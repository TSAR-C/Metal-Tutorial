//
//  Metal_3DApp.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/4.
//

import SwiftUI

@main
struct Metal_3DApp: App {
    @StateObject private var renderer = Renderer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(renderer)
    }
}
