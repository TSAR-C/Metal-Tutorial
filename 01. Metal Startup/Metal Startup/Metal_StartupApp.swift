//
//  Metal_StartupApp.swift
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

import SwiftUI

@main
struct Metal_StartupApp: App {
    @StateObject private var renderer = Renderer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(renderer)
    }
}
