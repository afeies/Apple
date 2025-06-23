//
//  SearchView.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import CoreData

struct SearchView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [PhotoEntry] = []
    @State private var isSearching = false
    @State private var showDateFilter = false
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var useDateFilter = false
    @State private var selectedEntry: PhotoEntry?
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    // Search Text Field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search by text content...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                performSearch()
                            }
                        
                        Button("Search") {
                            performSearch()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(searchText.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // Date Filter Toggle
                    HStack {
                        Toggle("Filter by Date Range", isOn: $useDateFilter)
                            .onChange(of: useDateFilter) { _ in
                                if useDateFilter {
                                    showDateFilter = true
                                }
                            }
                        
                        Spacer()
                        
                        if useDateFilter {
                            Button("Clear Filter") {
                                useDateFilter = false
                                showDateFilter = false
                                performSearch()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Date Range Picker
                    if showDateFilter && useDateFilter {
                        VStack(spacing: 8) {
                            HStack {
                                Text("From:")
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Text("To:")
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            Button("Apply Date Filter") {
                                performSearch()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Search Results
                if isSearching {
                    Spacer()
                    ProgressView("Searching...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your search terms or date filter")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(searchResults, id: \.self) { entry in
                            SearchResultRow(entry: entry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEntry = entry
                                    showingDetailView = true
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        searchText = ""
                        searchResults = []
                        useDateFilter = false
                        showDateFilter = false
                    }
                    .disabled(searchText.isEmpty && searchResults.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingDetailView) {
            if let entry = selectedEntry {
                PhotoEntryDetailView(entry: entry)
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request: NSFetchRequest<PhotoEntry> = PhotoEntry.fetchRequest()
        
        // Create search predicate
        var predicates: [NSPredicate] = []
        
        // Text search predicate
        let textPredicate = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
        predicates.append(textPredicate)
        
        // Date filter predicate
        if useDateFilter {
            let datePredicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", 
                                          startDate as NSDate, 
                                          endDate as NSDate)
            predicates.append(datePredicate)
        }
        
        // Combine predicates with AND
        if predicates.count > 1 {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            request.predicate = predicates.first
        }
        
        // Sort by timestamp (newest first)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PhotoEntry.timestamp, ascending: false)]
        
        do {
            searchResults = try viewContext.fetch(request)
        } catch {
            print("Error searching: \(error)")
            searchResults = []
        }
        
        isSearching = false
    }
}

struct SearchResultRow: View {
    let entry: PhotoEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let image = entry.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let text = entry.text, !text.isEmpty {
                        Text(text)
                            .font(.body)
                            .lineLimit(2)
                    }
                    
                    Text(entry.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let gps = entry.gps, !gps.isEmpty {
                        Text("📍 \(gps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
        .environmentObject(CoreDataManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
} 