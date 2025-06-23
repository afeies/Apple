//
//  PhotoEntryListView.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import CoreData

struct PhotoEntryListView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PhotoEntry.timestamp, ascending: false)],
        animation: .default)
    private var photoEntries: FetchedResults<PhotoEntry>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(photoEntries, id: \.self) { entry in
                    PhotoEntryRow(entry: entry)
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Photo Entries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            offsets.map { photoEntries[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting entry: \(error)")
            }
        }
    }
}

struct PhotoEntryRow: View {
    let entry: PhotoEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = entry.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            }
            
            if let text = entry.text, !text.isEmpty {
                Text(text)
                    .font(.body)
            }
            
            Text(entry.formattedTimestamp)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let gps = entry.gps, !gps.isEmpty {
                Text("GPS: \(gps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PhotoEntryListView()
        .environmentObject(CoreDataManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
} 