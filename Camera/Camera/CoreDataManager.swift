//
//  CoreDataManager.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Camera")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configure the context for better performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
            // Rollback changes on error
            context.rollback()
        }
    }
    
    func fetchPhotoEntries() -> [PhotoEntry] {
        let request: NSFetchRequest<PhotoEntry> = PhotoEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PhotoEntry.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching photo entries: \(error)")
            return []
        }
    }
    
    func createPhotoEntry(text: String?, gps: String?, image: Data?) -> PhotoEntry? {
        let entry = PhotoEntry(context: context)
        entry.text = text
        entry.gps = gps
        entry.image = image
        entry.timestamp = Date()
        
        do {
            try context.save()
            return entry
        } catch {
            print("Error creating photo entry: \(error)")
            context.rollback()
            return nil
        }
    }
    
    func deletePhotoEntry(_ entry: PhotoEntry) {
        context.delete(entry)
        
        do {
            try context.save()
        } catch {
            print("Error deleting photo entry: \(error)")
            context.rollback()
        }
    }
    
    func performSearch(searchText: String) -> [PhotoEntry] {
        let request: NSFetchRequest<PhotoEntry> = PhotoEntry.fetchRequest()
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PhotoEntry.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error performing search: \(error)")
            return []
        }
    }
} 