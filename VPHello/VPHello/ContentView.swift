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
            Spacer()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
