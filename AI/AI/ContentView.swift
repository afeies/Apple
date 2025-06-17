//
//  ContentView.swift
//  AI
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import PhotosUI

// MARK: - LLaVA Client
class LLaVAClient: ObservableObject {
    private let baseURL = "http://192.168.68.63:11434"
    private let session = URLSession.shared
    
    func analyzeImage(
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            completion(.failure(LLaVAError.imageProcessingFailed))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let request = LLaVARequest(
            model: "llava:latest",
            prompt: "What do you see in this image?",
            images: [base64Image],
            stream: false
        )
        
        sendRequest(request: request, completion: completion)
    }
    
    private func sendRequest(
        request: LLaVARequest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            completion(.failure(LLaVAError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(LLaVAError.noData))
                return
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            do {
                let response = try JSONDecoder().decode(LLaVAResponse.self, from: data)
                completion(.success(response.response))
            } catch {
                print("JSON decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Data Models
struct LLaVARequest: Codable {
    let model: String
    let prompt: String
    let images: [String]
    let stream: Bool
}

struct LLaVAResponse: Codable {
    let response: String
    let done: Bool
}

enum LLaVAError: Error, LocalizedError {
    case invalidURL
    case noData
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .imageProcessingFailed:
            return "Failed to process image"
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @StateObject private var llavaClient = LLaVAClient()
    @State private var selectedImage: UIImage?
    @State private var response = ""
    @State private var isLoading = false
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Image Section
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
                    .onTapGesture {
                        showingImagePicker = true
                    }
            } else {
                Button(action: {
                    showingImagePicker = true
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Select Photo")
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            
            // Analyze Button
            if selectedImage != nil {
                Button(action: analyzeImage) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isLoading ? "Analyzing..." : "Analyze")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            
            // Response Section
            if !response.isEmpty {
                ScrollView {
                    Text(response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        isLoading = true
        response = ""
        
        llavaClient.analyzeImage(image: image) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let text):
                    response = text
                case .failure(let error):
                    response = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
