//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rectangles: [RectangleData] = []
    @State private var windowSize: CGSize = CGSize(width: 400, height: 600) // Default size
    @Environment(\.openWindow) private var openWindow
    @Binding var windowCount: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to VPHello!")
                .font(.largeTitle)
                .padding()
            
            HStack(spacing: 15) {
                Button("Add Note") {
                    let centerX = windowSize.width / 2
                    let centerY = windowSize.height / 2
                    let newRectangle = RectangleData(
                        id: UUID(),
                        position: CGPoint(x: centerX, y: centerY),
                        size: CGSize(width: 200, height: 150)
                    )
                    rectangles.append(newRectangle)
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("New Window") {
                    openWindow(id: "noteWindow")
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            ScrollView {
                ZStack {
                    ForEach(rectangles) { rectangle in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: rectangle.size.width, height: rectangle.size.height)
                            .position(rectangle.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let index = rectangles.firstIndex(where: { $0.id == rectangle.id }) {
                                            rectangles[index].position = value.location
                                        }
                                    }
                            )
                    }
                }
                .frame(minHeight: 600)
            }
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    windowSize = geometry.size
                }
            })
            
            Spacer()
        }
        .padding()
    }
}

struct NoteWindowView: View {
    let windowID: Int
    @State private var rectangles: [RectangleData] = []
    @State private var windowSize: CGSize = CGSize(width: 400, height: 600)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Window")
                .font(.largeTitle)
                .padding()
            
            Button("Add Note") {
                let centerX = windowSize.width / 2
                let centerY = windowSize.height / 2
                let newRectangle = RectangleData(
                    id: UUID(),
                    position: CGPoint(x: centerX, y: centerY),
                    size: CGSize(width: 200, height: 150)
                )
                rectangles.append(newRectangle)
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            ScrollView {
                ZStack {
                    ForEach(rectangles) { rectangle in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: rectangle.size.width, height: rectangle.size.height)
                            .position(rectangle.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let index = rectangles.firstIndex(where: { $0.id == rectangle.id }) {
                                            rectangles[index].position = value.location
                                        }
                                    }
                            )
                    }
                }
                .frame(minHeight: 600)
            }
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    windowSize = geometry.size
                }
            })
            
            Spacer()
        }
        .padding()
    }
}

struct RectangleData: Identifiable {
    let id: UUID
    var position: CGPoint
    var size: CGSize
}

#Preview(windowStyle: .automatic) {
    ContentView(windowCount: .constant(1))
}
