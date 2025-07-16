//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to VPHello!")
                .font(.largeTitle)
                .padding()
            // Simple 2D shapes
            HStack(spacing: 30) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
            }
            // Simple 3D shapes
            HStack(spacing: 30) {
                // Sphere from asset bundle
                Model3D(named: "Scene", bundle: realityKitContentBundle)
                    .frame(width: 100, height: 100)
                // Box primitive
                RealityView { content in
                    let box = ModelEntity(mesh: .generateBox(size: 0.1))
                    content.add(box)
                }
                .frame(width: 100, height: 100)
                // Plane primitive (flat rectangle)
                RealityView { content in
                    let plane = ModelEntity(mesh: .generatePlane(width: 0.12, depth: 0.08))
                    content.add(plane)
                }
                .frame(width: 100, height: 100)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
