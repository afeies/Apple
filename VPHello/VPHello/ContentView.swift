//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Binding var windowCount: Int
    @State private var isEditingTitle = false
    @State private var windowTitle = "Welcome to VPHello!"
    @State private var noteText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if isEditingTitle {
                TextField("Window Title", text: $windowTitle, onCommit: { isEditingTitle = false })
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { isEditingTitle = false }
                    .onDisappear { isEditingTitle = false }
                    .padding(.top)
            } else {
                Button(action: { isEditingTitle = true }) {
                    Text(windowTitle)
                        .font(.largeTitle)
                        .padding(.horizontal)
                }
                .buttonStyle(TitleButtonStyle())
                .padding(.top)
            }
            
            Button("New Window") {
                openWindow(id: "noteWindow")
            }
            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            TextEditor(text: $noteText)
                .font(.title2)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct NoteWindowView: View {
    let windowID: Int
    @Environment(\.openWindow) private var openWindow
    @State private var isEditingTitle = false
    @State private var windowTitle = "New Window"
    @State private var noteText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if isEditingTitle {
                TextField("Window Title", text: $windowTitle, onCommit: { isEditingTitle = false })
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { isEditingTitle = false }
                    .onDisappear { isEditingTitle = false }
                    .padding(.top)
            } else {
                Button(action: { isEditingTitle = true }) {
                    Text(windowTitle)
                        .font(.largeTitle)
                        .padding(.horizontal)
                }
                .buttonStyle(TitleButtonStyle())
                .padding(.top)
            }
            
            Button("New Window") {
                openWindow(id: "noteWindow")
            }
            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            TextEditor(text: $noteText)
                .font(.title2)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct TitleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(windowCount: .constant(1))
}
