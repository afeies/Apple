//
//  PhotoEntry+Extensions.swift
//  Camera
//
//  Created by Alex Feies on 6/13/25.
//

import Foundation
import CoreData
import UIKit

extension PhotoEntry {
    var formattedTimestamp: String {
        guard let timestamp = timestamp else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var uiImage: UIImage? {
        guard let imageData = image else { return nil }
        return UIImage(data: imageData)
    }
    
    var gpsCoordinates: (latitude: Double, longitude: Double)? {
        guard let gpsString = gps else { return nil }
        let components = gpsString.components(separatedBy: ",")
        guard components.count == 2,
              let latitude = Double(components[0].trimmingCharacters(in: .whitespaces)),
              let longitude = Double(components[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        return (latitude, longitude)
    }
    
    func setGPS(latitude: Double, longitude: Double) {
        self.gps = "\(latitude), \(longitude)"
    }
    
    func setImage(_ image: UIImage) {
        self.image = image.jpegData(compressionQuality: 0.8)
    }
} 