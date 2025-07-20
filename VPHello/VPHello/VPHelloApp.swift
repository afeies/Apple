//
//  VPHelloApp.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI

@main
struct VPHelloApp: App {
    @State private var windowCount: Int = 1

    var body: some Scene {
        WindowGroup("Note Window", id: "main") {
            ContentView(windowCount: $windowCount)
        }
        
        WindowGroup("Note Window", id: "noteWindow") {
            NoteWindowView(windowID: windowCount)
        }
    }
}
