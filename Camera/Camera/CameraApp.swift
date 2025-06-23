//
//  CameraApp.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import CoreData

@main
struct CameraApp: App {
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context)
                .environmentObject(coreDataManager)
        }
    }
}
