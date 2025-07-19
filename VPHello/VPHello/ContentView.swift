//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DraggableShape<Content: View>: View {
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    let content: () -> Content
    var body: some View {
        content()
            .offset(offset)
            .scaleEffect(scale)
            .gesture(
                DragGesture()
                    .onChanged { value in offset = value.translation }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in scale = value }
            )
    }
}

struct DraggableRealityView: View {
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    let entityBuilder: () -> ModelEntity
    var body: some View {
        RealityView { content in
            let entity = entityBuilder()
            content.add(entity)
        }
        .offset(offset)
        .scaleEffect(scale)
        .gesture(
            DragGesture()
                .onChanged { value in offset = value.translation }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in scale = value }
        )
    }
}

struct ContentView: View {

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to VPHello!")
                .font(.largeTitle)
                .padding()
            // Simple 2D shapes
            HStack(spacing: 30) {
                DraggableShape {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                }
                DraggableShape {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                }
                DraggableShape {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.orange)
                        .frame(width: 100, height: 100)
                }
            }
            // Simple 3D shapes
            HStack {
                Spacer()
                DraggableShape {
                    Model3D(named: "Scene", bundle: realityKitContentBundle)
                        .frame(width: 100, height: 100)
                }
                Spacer()
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
