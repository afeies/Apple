import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var isAnalyzing = false
    @State private var analysisResult = "Press Start to begin analysis"
    
    var body: some View {
        VStack(spacing: 20) {
            // Camera View
            CameraView(cameraManager: cameraManager)
                .frame(height: 400)
                .cornerRadius(10)
                .padding(.horizontal)
            
            // Start/Stop Button
            Button(action: {
                if isAnalyzing {
                    stopAnalysis()
                } else {
                    startAnalysis()
                }
            }) {
                Text(isAnalyzing ? "Stop Analysis" : "Start Analysis")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isAnalyzing ? Color.red : Color.blue)
                    .cornerRadius(10)
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
    
    private func startAnalysis() {
        isAnalyzing = true
        analysisResult = "Starting analysis..."
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if !isAnalyzing {
                timer.invalidate()
                return
            }
            
            Task {
                await captureAndAnalyze()
            }
        }
    }
    
    private func stopAnalysis() {
        isAnalyzing = false
        analysisResult = "Analysis stopped"
    }
    
    private func captureAndAnalyze() async {
        let image: UIImage
        
        #if targetEnvironment(simulator)
        // Use test image for simulator
        image = createTestImage()
        #else
        // Capture from camera
        guard let capturedImage = cameraManager.captureImage() else {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to capture image"
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
        
        let text = "Test Image\nSimulator Mode"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        let textRect = CGRect(x: 50, y: 70, width: 200, height: 60)
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    private func sendImageToModel(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to convert image to data"
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
                            "text": "Describe what you see in this image."
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
                    }
                } else {
                    DispatchQueue.main.async {
                        self.analysisResult = "Failed to parse response"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.analysisResult = "Server error: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.analysisResult = "Network error: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var currentImage: UIImage?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        #if !targetEnvironment(simulator)
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        #endif
    }
    
    func captureImage() -> UIImage? {
        return currentImage
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async {
            self.currentImage = image
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        #if targetEnvironment(simulator)
        // Show placeholder for simulator
        let label = UILabel()
        label.text = "Camera Preview\n(Simulator Mode)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor),
            label.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        #else
        // Real camera preview
        guard let captureSession = cameraManager.captureSession else { return view }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Update frame when view changes
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        #if !targetEnvironment(simulator)
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
        #endif
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
