//
//  Camera.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/9.
//

import simd
import SwiftUI

class FPSController {
    unowned var camera: Camera
    var mouse: CGPoint?
    
    var viewLock = true
    var motionLock = true
    
    enum Direction: Character {
        case forward = "w"
        case backward = "s"
        case left = "a"
        case right = "d"
        case up = "e"
        case down = "q"
    }
    
    var movingDirections: Set<Direction> = []
    
    init(camera: Camera) {
        self.camera = camera
    }
    
    func update(_ deltaT: Float) {
        updateMouse()
        updateMotion(deltaT)
    }
    
    private func updateMouse() {
        if let mouse {
            let currentMouseLocation = NSEvent.mouseLocation
            
            if !viewLock {
                let dx = Float(currentMouseLocation.x - mouse.x)
                let dy = Float(currentMouseLocation.y - mouse.y)
                
                camera.yaw = camera.yaw - dx * 0.1
                camera.pitch = camera.pitch + dy * 0.1
            }
            
            self.mouse = currentMouseLocation
        } else {
            mouse = NSEvent.mouseLocation
        }
    }
    
    private func updateMotion(_ deltaT: Float) {
        var dir = SIMD3<Float>.zero
        
        for direction in movingDirections {
            let directionComponent = switch direction {
            case .backward: -camera.front
            case .forward: camera.front
            case .up: camera.up
            case .down: -camera.up
            case .left: -camera.right
            case .right: camera.right
            }
            dir = dir + directionComponent
        }
        
        if length(dir) > 0 {
            let velocity = normalize(dir)
            
            camera.position = camera.position + velocity * deltaT
        }
    }
}

class Camera {
    var yaw: Float = .zero
    var pitch: Float = .zero
    var roll: Float = .zero
    
    var right: SIMD3<Float> { euler[0] }
    var front: SIMD3<Float> { euler[1] }
    var up   : SIMD3<Float> { euler[2] }
    
    var position: SIMD3<Float> = .zero
    
    var fov: Float = 45
    var aspectRatio: Float = 1
    var near: Float = 1
    var far: Float = 100
    
    var projection: simd_float4x4 {
        let tangentTheta = tan(fov * Float.pi / 360)
        let tangentPhi = tangentTheta * aspectRatio
        
        return simd_float4x4(rows: [
            SIMD4<Float>(1 / tangentPhi, 0, 0, 0),
            SIMD4<Float>(0, 1 / tangentTheta, 0, 0),
            SIMD4<Float>(0, 0, -far / (far - near), -far * near / (far - near)),
            SIMD4<Float>(0, 0, -1, 0),
        ])
    }
    
    var view: simd_float4x4 {
        var t = simd_float4x4(1)
        t[3] = SIMD4<Float>(-position, 1)
        
        return simd_float4x4(rows: [
            SIMD4<Float>(right, 0),
            SIMD4<Float>(up, 0),
            SIMD4<Float>(-front, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ]) * t
    }
    
    private var euler: simd_float3x3 {
        let yaw = yaw * Float.pi / 180
        let pitch = pitch * Float.pi / 180
        let roll = roll * Float.pi / 180
        
        return simd_float3x3(rows: [
            SIMD3<Float>(cos(yaw), -sin(yaw), 0),
            SIMD3<Float>(sin(yaw),  cos(yaw), 0),
            SIMD3<Float>(0, 0, 1)
        ]) * simd_float3x3(rows: [
            SIMD3<Float>(1, 0, 0),
            SIMD3<Float>(0, cos(pitch), -sin(pitch)),
            SIMD3<Float>(0, sin(pitch),  cos(pitch))
        ]) * simd_float3x3(rows: [
            SIMD3<Float>(cos(roll), 0, sin(roll)),
            SIMD3<Float>(0, 1, 0),
            SIMD3<Float>(-sin(roll), 0, cos(roll))
        ])
    }
}
