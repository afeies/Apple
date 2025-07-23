//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import Speech
import AVFoundation

struct HomeView: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        VStack(spacing: 40) {
            Text("Leetcode Studying")
                .font(.system(size: 48, weight: .bold))
                .padding(.top, 60)
            Button("Two Pointers") {
                openWindow(id: "main")
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            Button("Sliding Window") {
                openWindow(id: "slidingWindow")
            }
            .font(.title)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            Button("Prefix Sum") {
                openWindow(id: "prefixSum")
            }
            .font(.title)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Binding var windowCount: Int
    @State private var isEditingTitle = false
    @State private var windowTitle = "Two Pointers"
    @State private var noteText = "left, right = 0, len(arr) - 1\n    while left < right:\n        if some_condition:\n            left += 1\n        elif other_condition:\n            right -= 1\n        else:\n            left += 1\n            right -= 1"
    
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

struct SlidingWindowNoteView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var isEditingTitle = false
    @State private var windowTitle = "Sliding Window"
    @State private var noteText = "    left = 0\n    window_sum = 0\n    max_sum = float('-inf')\n    for right in range(len(arr)):\n        window_sum += arr[right]  \n        if right - left + 1 == k:\n            max_sum = max(max_sum, window_sum)\n            window_sum -= arr[left]\n            left += 1\n    return max_sum"
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

struct PrefixSumNoteView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var isEditingTitle = false
    @State private var windowTitle = "Prefix Sum"
    @State private var noteText = "prefix = [0] * (len(nums) + 1)\nfor i in range(len(nums)):\n    prefix[i + 1] = prefix[i] + nums[i]"
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
