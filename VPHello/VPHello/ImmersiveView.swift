//
//  ImmersiveView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var cubePosition: SIMD3<Float> = [0, 1.5, -1.5]
    @State private var cubeScale: Float = 1.0

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            
            // Add interactive white cube
            let cube = ModelEntity(mesh: .generateBox(size: 0.2))
            cube.name = "InteractiveCube"
            cube.position = cubePosition
            cube.scale = [cubeScale, cubeScale, cubeScale]
            // Add a white material
            let whiteMaterial = SimpleMaterial(color: .white, isMetallic: false)
            cube.model?.materials = [whiteMaterial]
            content.add(cube)
            
        } update: { content in
            // Update cube position and scale
            if let cube = content.entities.first(where: { $0.name == "InteractiveCube" }) {
                cube.position = cubePosition
                cube.scale = [cubeScale, cubeScale, cubeScale]
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation
                    let sensitivity: Float = 0.01
                    cubePosition.x += Float(translation.width) * sensitivity
                    cubePosition.z += Float(translation.height) * sensitivity
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    cubeScale = Float(value)
                }
        )
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
