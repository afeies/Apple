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
        WindowGroup("Home", id: "home") {
            HomeView()
        }
        .defaultSize(width: 900, height: 900)
        
        WindowGroup("Note Window", id: "main") {
            ContentView(windowCount: $windowCount)
        }
        .defaultSize(width: 1750, height: 1250)
        
        WindowGroup("Sliding Window Note", id: "slidingWindow") {
            SlidingWindowNoteView()
        }
        .defaultSize(width: 1750, height: 1250)
        
        WindowGroup("Prefix Sum Note", id: "prefixSum") {
            PrefixSumNoteView()
        }
        .defaultSize(width: 1750, height: 1250)
        
        WindowGroup("Note Window", id: "noteWindow") {
            NoteWindowView(windowID: windowCount)
        }
        .defaultSize(width: 1750, height: 1250)
    }
}
