//
//  PhotoEntryDetailView.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct PhotoEntryDetailView: View {
    let entry: PhotoEntry
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var showingMap = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section
                    if let image = entry.uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No Image Available")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                }
                            )
                    }
                    
                    // Text Content Section
                    if let text = entry.text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .foregroundColor(.blue)
                                Text("Analysis")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            Text(text)
                                .font(.body)
                                .lineSpacing(4)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Timestamp Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Captured")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        Text(entry.formattedTimestamp)
                            .font(.body)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Embedded Map Section
                    if entry.gpsCoordinates != nil || locationManager.currentLocation != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.red)
                                Text("Location")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            // Small embedded map
                            EmbeddedMapView(entry: entry, currentLocation: locationManager.currentLocation)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                                .onTapGesture {
                                    showingMap = true
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Photo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        shareEntry()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            MapView(entry: entry, currentLocation: locationManager.currentLocation)
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
    
    private func shareEntry() {
        var shareItems: [Any] = []
        
        if let image = entry.uiImage {
            shareItems.append(image)
        }
        
        if let text = entry.text {
            shareItems.append(text)
        }
        
        if let gpsCoordinates = entry.gpsCoordinates {
            let locationText = "Location: \(gpsCoordinates.latitude), \(gpsCoordinates.longitude)"
            shareItems.append(locationText)
        }
        
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct EmbeddedMapView: View {
    let entry: PhotoEntry
    let currentLocation: CLLocation?
    @State private var region: MKCoordinateRegion
    
    init(entry: PhotoEntry, currentLocation: CLLocation?) {
        self.entry = entry
        self.currentLocation = currentLocation
        
        // Initialize region based on photo location or current location
        if let gpsCoordinates = entry.gpsCoordinates {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: gpsCoordinates.latitude,
                    longitude: gpsCoordinates.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else if let currentLocation = currentLocation {
            self._region = State(initialValue: MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            // Fallback to a default location
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                VStack {
                    Image(systemName: annotation.iconName)
                        .font(.caption)
                        .foregroundColor(annotation.color)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 20, height: 20)
                        )
                    
                    Text(annotation.title)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.white)
                        .cornerRadius(2)
                        .shadow(radius: 1)
                }
            }
        }
        .onAppear {
            setupMapRegion()
        }
    }
    
    private var mapAnnotations: [CustomMapAnnotation] {
        var annotations: [CustomMapAnnotation] = []
        
        // Add photo location annotation
        if let gpsCoordinates = entry.gpsCoordinates {
            annotations.append(CustomMapAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: gpsCoordinates.latitude,
                    longitude: gpsCoordinates.longitude
                ),
                title: "Photo",
                iconName: "camera",
                color: .red
            ))
        }
        
        // Add current location annotation
        if let currentLocation = currentLocation {
            annotations.append(CustomMapAnnotation(
                coordinate: currentLocation.coordinate,
                title: "Current",
                iconName: "location",
                color: .blue
            ))
        }
        
        return annotations
    }
    
    private func setupMapRegion() {
        var coordinates: [CLLocationCoordinate2D] = []
        
        if let gpsCoordinates = entry.gpsCoordinates {
            coordinates.append(CLLocationCoordinate2D(
                latitude: gpsCoordinates.latitude,
                longitude: gpsCoordinates.longitude
            ))
        }
        
        if let currentLocation = currentLocation {
            coordinates.append(currentLocation.coordinate)
        }
        
        if coordinates.count == 1 {
            // Single location - center on it with close zoom
            region = MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else if coordinates.count == 2 {
            // Two locations - show both with appropriate zoom
            let minLat = min(coordinates[0].latitude, coordinates[1].latitude)
            let maxLat = max(coordinates[0].latitude, coordinates[1].latitude)
            let minLon = min(coordinates[0].longitude, coordinates[1].longitude)
            let maxLon = max(coordinates[0].longitude, coordinates[1].longitude)
            
            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2
            let latDelta = (maxLat - minLat) * 1.5
            let lonDelta = (maxLon - minLon) * 1.5
            
            // Ensure minimum zoom level for visibility
            let minSpan = 0.01
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, minSpan),
                    longitudeDelta: max(lonDelta, minSpan)
                )
            )
        }
    }
}

struct MapView: View {
    let entry: PhotoEntry
    let currentLocation: CLLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    init(entry: PhotoEntry, currentLocation: CLLocation?) {
        self.entry = entry
        self.currentLocation = currentLocation
        
        // Initialize region based on photo location or current location
        if let gpsCoordinates = entry.gpsCoordinates {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: gpsCoordinates.latitude,
                    longitude: gpsCoordinates.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else if let currentLocation = currentLocation {
            self._region = State(initialValue: MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            // Fallback to a default location (you can change this)
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    VStack {
                        Image(systemName: annotation.iconName)
                            .font(.title2)
                            .foregroundColor(annotation.color)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                            )
                        
                        Text(annotation.title)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.white)
                            .cornerRadius(4)
                            .shadow(radius: 1)
                    }
                }
            }
            .navigationTitle("Location Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            setupMapRegion()
        }
    }
    
    private var mapAnnotations: [CustomMapAnnotation] {
        var annotations: [CustomMapAnnotation] = []
        
        // Add photo location annotation
        if let gpsCoordinates = entry.gpsCoordinates {
            annotations.append(CustomMapAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: gpsCoordinates.latitude,
                    longitude: gpsCoordinates.longitude
                ),
                title: "Photo Location",
                iconName: "camera",
                color: .red
            ))
        }
        
        // Add current location annotation
        if let currentLocation = currentLocation {
            annotations.append(CustomMapAnnotation(
                coordinate: currentLocation.coordinate,
                title: "Current Location",
                iconName: "location",
                color: .blue
            ))
        }
        
        return annotations
    }
    
    private func setupMapRegion() {
        var coordinates: [CLLocationCoordinate2D] = []
        
        if let gpsCoordinates = entry.gpsCoordinates {
            coordinates.append(CLLocationCoordinate2D(
                latitude: gpsCoordinates.latitude,
                longitude: gpsCoordinates.longitude
            ))
        }
        
        if let currentLocation = currentLocation {
            coordinates.append(currentLocation.coordinate)
        }
        
        if coordinates.count == 1 {
            // Single location - center on it with close zoom
            region = MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        } else if coordinates.count == 2 {
            // Two locations - show both with appropriate zoom
            let minLat = min(coordinates[0].latitude, coordinates[1].latitude)
            let maxLat = max(coordinates[0].latitude, coordinates[1].latitude)
            let minLon = min(coordinates[0].longitude, coordinates[1].longitude)
            let maxLon = max(coordinates[0].longitude, coordinates[1].longitude)
            
            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2
            let latDelta = (maxLat - minLat) * 1.5
            let lonDelta = (maxLon - minLon) * 1.5
            
            // Ensure minimum zoom level for visibility
            let minSpan = 0.005
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, minSpan),
                    longitudeDelta: max(lonDelta, minSpan)
                )
            )
        }
    }
}

struct CustomMapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let iconName: String
    let color: Color
}

#Preview {
    let context = CoreDataManager.shared.context
    let sampleEntry = PhotoEntry(context: context)
    sampleEntry.text = "This is a sample analysis of a beautiful landscape photo."
    sampleEntry.timestamp = Date()
    sampleEntry.gps = "37.7749, -122.4194"
    
    return PhotoEntryDetailView(entry: sampleEntry)
        .environmentObject(CoreDataManager.shared)
        .environment(\.managedObjectContext, context)
} 