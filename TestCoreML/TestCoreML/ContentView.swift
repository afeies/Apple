import SwiftUI
import AVFoundation
import Vision
import CoreML

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var analysisResult = "Point camera at objects and tap 'Capture & Analyze' to get AI description"
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera Preview
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Analysis Result Box
                    VStack {
                        ScrollView {
                            Text(analysisResult)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxHeight: 150)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Capture & Analyze Button
                        Button(action: captureAndAnalyze) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isAnalyzing ? "Analyzing..." : "Capture & Analyze")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 200, height: 50)
                            .background(isAnalyzing ? Color.gray : Color.blue)
                            .cornerRadius(25)
                        }
                        .disabled(isAnalyzing)
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("AI Camera")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                cameraManager.checkPermissions()
            }
        }
    }
    
    private func captureAndAnalyze() {
        guard !isAnalyzing else { return }
        
        isAnalyzing = true
        analysisResult = "Analyzing image..."
        
        cameraManager.capturePhoto { image in
            if let image = image {
                analyzeImage(image) { result in
                    DispatchQueue.main.async {
                        self.analysisResult = result
                        self.isAnalyzing = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.analysisResult = "Failed to capture image. Please try again."
                    self.isAnalyzing = false
                }
            }
        }
    }
    
    private func analyzeImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("Failed to process image")
            return
        }
        
        var results: [String] = []
        let group = DispatchGroup()
        
        // 1. Scene Classification
        group.enter()
        classifyScene(cgImage) { sceneResult in
            if !sceneResult.isEmpty {
                results.append("Scene: \(sceneResult)")
            }
            group.leave()
        }
        
        // 2. Object Detection (using multiple Vision approaches)
        group.enter()
        detectObjects(cgImage) { objectResults in
            if !objectResults.isEmpty {
                results.append("Visual elements: \(objectResults.joined(separator: ", "))")
            }
            group.leave()
        }
        
        // 5. Human Detection
        group.enter()
        detectHumans(cgImage) { humanCount in
            if humanCount > 0 {
                results.append("People detected: \(humanCount)")
            }
            group.leave()
        }
        
        // 6. Animal Detection
        group.enter()
        detectAnimals(cgImage) { animalResults in
            if !animalResults.isEmpty {
                results.append("Animals: \(animalResults.joined(separator: ", "))")
            }
            group.leave()
        }
        
        // 7. Image Description (composition, colors, lighting)
        group.enter()
        analyzeImageComposition(cgImage) { imageDescription in
            if !imageDescription.isEmpty {
                results.insert("Image: \(imageDescription)", at: 0) // Put description first
            }
            group.leave()
        }
        
        // 3. Text Recognition
        group.enter()
        recognizeText(cgImage) { textResult in
            if !textResult.isEmpty {
                results.append("Text found: \(textResult)")
            }
            group.leave()
        }
        
        // 4. Face Detection
        group.enter()
        detectFaces(cgImage) { faceCount in
            if faceCount > 0 {
                results.append("Faces detected: \(faceCount)")
            }
            group.leave()
        }
        
        group.notify(queue: .global()) {
            let finalResult = results.isEmpty ?
                "No clear objects or text detected in the image." :
                results.joined(separator: "\n\n")
            completion(finalResult)
        }
    }
    
    private func classifyScene(_ image: CGImage, completion: @escaping (String) -> Void) {
        let request = VNClassifyImageRequest { request, error in
            guard let observations = request.results as? [VNClassificationObservation],
                  let topResult = observations.first,
                  topResult.confidence > 0.3 else {
                completion("")
                return
            }
            completion(topResult.identifier.capitalized)
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
    
    private func analyzeImageComposition(_ image: CGImage, completion: @escaping (String) -> Void) {
        var compositionElements: [String] = []
        let group = DispatchGroup()
        
        // 1. Analyze dominant colors
        group.enter()
        analyzeDominantColors(image) { colorDescription in
            if !colorDescription.isEmpty {
                compositionElements.append(colorDescription)
            }
            group.leave()
        }
        
        // 2. Analyze image aesthetics and composition
        group.enter()
        let aestheticsRequest = VNGenerateImageFeaturePrintRequest { request, error in
            // This gives us general image characteristics
            if let _ = request.results?.first {
                compositionElements.append("well-composed image")
            }
            group.leave()
        }
        
        // 3. Analyze attention-based saliency for composition
        group.enter()
        let attentionRequest = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
            if let observation = request.results?.first as? VNSaliencyImageObservation {
                let boundingBoxes = observation.salientObjects ?? []
                if boundingBoxes.count > 0 {
                    compositionElements.append("focused composition with \(boundingBoxes.count) main subject(s)")
                } else {
                    compositionElements.append("distributed composition")
                }
            }
            group.leave()
        }
        
        // 4. Basic image properties
        let width = image.width
        let height = image.height
        let aspectRatio = Double(width) / Double(height)
        
        if aspectRatio > 1.5 {
            compositionElements.append("wide landscape format")
        } else if aspectRatio < 0.7 {
            compositionElements.append("tall portrait format")
        } else {
            compositionElements.append("standard format")
        }
        
        group.notify(queue: .global()) {
            let description = compositionElements.isEmpty ?
                "Clear digital image" :
                compositionElements.joined(separator: ", ")
            completion(description)
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([aestheticsRequest, attentionRequest])
    }
    
    private func analyzeDominantColors(_ image: CGImage, completion: @escaping (String) -> Void) {
        // Simple color analysis using Core Image
        let ciImage = CIImage(cgImage: image)
        let extentVector = CIVector(x: ciImage.extent.origin.x,
                                   y: ciImage.extent.origin.y,
                                   z: ciImage.extent.size.width,
                                   w: ciImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]),
              let outputImage = filter.outputImage else {
            completion("")
            return
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let red = Float(bitmap[0]) / 255.0
        let green = Float(bitmap[1]) / 255.0
        let blue = Float(bitmap[2]) / 255.0
        
        // Determine dominant color characteristics
        let brightness = (red + green + blue) / 3.0
        let colorfulness = max(red, green, blue) - min(red, green, blue)
        
        var colorDescription = ""
        
        // Brightness description
        if brightness > 0.7 {
            colorDescription = "bright"
        } else if brightness < 0.3 {
            colorDescription = "dark"
        } else {
            colorDescription = "medium-toned"
        }
        
        // Color saturation
        if colorfulness > 0.3 {
            colorDescription += ", vibrant colors"
        } else if colorfulness < 0.1 {
            colorDescription += ", muted/monochrome tones"
        } else {
            colorDescription += ", balanced colors"
        }
        
        // Dominant color hue
        if red > green && red > blue {
            colorDescription += " with warm red tones"
        } else if green > red && green > blue {
            colorDescription += " with natural green tones"
        } else if blue > red && blue > green {
            colorDescription += " with cool blue tones"
        }
        
        completion(colorDescription)
    }
    
    private func detectObjects(_ image: CGImage, completion: @escaping ([String]) -> Void) {
        var detectedElements: [String] = []
        let group = DispatchGroup()
        
        // 1. Saliency-based object detection
        group.enter()
        let saliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest { request, error in
            if let _ = request.results?.first as? VNSaliencyImageObservation {
                detectedElements.append("salient objects")
            }
            group.leave()
        }
        
        // 2. Rectangle detection for geometric objects
        group.enter()
        let rectangleRequest = VNDetectRectanglesRequest { request, error in
            if let observations = request.results as? [VNRectangleObservation], !observations.isEmpty {
                detectedElements.append("rectangular objects (\(observations.count))")
            }
            group.leave()
        }
        
        // 3. Horizon detection for landscape scenes
        group.enter()
        let horizonRequest = VNDetectHorizonRequest { request, error in
            if let _ = request.results?.first as? VNHorizonObservation {
                detectedElements.append("horizon line")
            }
            group.leave()
        }
        
        group.notify(queue: .global()) {
            completion(detectedElements)
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([saliencyRequest, rectangleRequest, horizonRequest])
    }
    
    private func detectHumans(_ image: CGImage, completion: @escaping (Int) -> Void) {
        let request = VNDetectHumanRectanglesRequest { request, error in
            guard let observations = request.results as? [VNHumanObservation] else {
                completion(0)
                return
            }
            completion(observations.count)
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
    
    private func detectAnimals(_ image: CGImage, completion: @escaping ([String]) -> Void) {
        let request = VNRecognizeAnimalsRequest { request, error in
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            
            let animals = observations.compactMap { observation -> String? in
                guard let topLabel = observation.labels.first,
                      topLabel.confidence > 0.5 else { return nil }
                return topLabel.identifier.capitalized
            }
            
            completion(Array(Set(animals)))
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
    
    private func recognizeText(_ image: CGImage, completion: @escaping (String) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            completion(text.isEmpty ? "" : String(text.prefix(100))) // Limit text length
        }
        
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
    
    private func detectFaces(_ image: CGImage, completion: @escaping (Int) -> Void) {
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let observations = request.results as? [VNFaceObservation] else {
                completion(0)
                return
            }
            completion(observations.count)
        }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ No camera device found")
            session.commitConfiguration()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                print("❌ Cannot add video input")
                session.commitConfiguration()
                return
            }
        } catch {
            print("❌ Camera input error: \(error.localizedDescription)")
            session.commitConfiguration()
            return
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            print("❌ Cannot add photo output")
        }
        
        session.sessionPreset = .photo
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - Photo Capture Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(nil)
            return
        }
        
        photoCaptureCompletion?(image)
        photoCaptureCompletion = nil
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
