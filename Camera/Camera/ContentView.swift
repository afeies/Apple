import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var speechManager = SpeechManager()
    @State private var analysisResult = "Press Capture to analyze an image"
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Camera View
            CameraView(cameraManager: cameraManager)
                .frame(height: 400)
                .cornerRadius(10)
                .padding(.horizontal)
            
            // Control Buttons
            HStack(spacing: 20) {
                // Capture Button
                Button(action: {
                    captureAndAnalyze()
                }) {
                    Text(isProcessing ? "Processing..." : "Capture & Analyze")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(isProcessing ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isProcessing)
                
                // Speech Button
                Button(action: {
                    if speechManager.isSpeaking {
                        speechManager.stopSpeaking()
                    } else {
                        speechManager.speak(text: analysisResult)
                    }
                }) {
                    Image(systemName: speechManager.isSpeaking ? "speaker.slash.fill" : "speaker.2.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(speechManager.isSpeaking ? Color.red : Color.green)
                        .cornerRadius(10)
                }
            }
            
            // Analysis Result
            ScrollView {
                Text(analysisResult)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private func captureAndAnalyze() {
        guard !isProcessing else { return }
        
        isProcessing = true
        analysisResult = "Capturing and analyzing image..."
        
        Task {
            await performImageAnalysis()
        }
    }
    
    private func performImageAnalysis() async {
        let image: UIImage
        
        #if targetEnvironment(simulator)
        // Use test image for simulator
        image = createTestImage()
        #else
        // Capture from camera
        guard let capturedImage = cameraManager.captureImage() else {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to capture image"
                self.isProcessing = false
            }
            return
        }
        image = capturedImage
        #endif
        
        // Send to SmolVLM
        await sendImageToModel(image)
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 300, height: 200)
        UIGraphicsBeginImageContext(size)
        
        // Create a simple test image with text
        let rect = CGRect(origin: .zero, size: size)
        UIColor.lightGray.setFill()
        UIRectFill(rect)
        
        let text = "Test Image\nSimulator Mode\nThis is a sample analysis result."
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        let textRect = CGRect(x: 20, y: 50, width: 260, height: 100)
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    private func sendImageToModel(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to convert image to data"
                self.isProcessing = false
            }
            return
        }
        
        let base64String = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "SmolVLM",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Describe what you see in this image in detail."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64String)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300,
            "stream": false
        ]
        
        guard let url = URL(string: "http://192.168.68.63:8080/v1/chat/completions") else {
            DispatchQueue.main.async {
                self.analysisResult = "Invalid URL"
                self.isProcessing = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    DispatchQueue.main.async {
                        self.analysisResult = content
                        self.isProcessing = false
                        // Automatically speak the result
                        self.speechManager.speak(text: content)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.analysisResult = "Failed to parse response"
                        self.isProcessing = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.analysisResult = "Server error: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    self.isProcessing = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.analysisResult = "Network error: \(error.localizedDescription)"
                self.isProcessing = false
            }
        }
    }
}

#Preview {
    ContentView()
}
