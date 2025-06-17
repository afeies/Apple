import SwiftUI
import AVFoundation
import UIKit

// MARK: - Saved Color Model
struct SavedColor: Identifiable, Codable {
    let id = UUID()
    let hex: String
    let red: Double
    let green: Double
    let blue: Double
    let timestamp: Date
    
    var color: Color {
        Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Color Storage Manager
class ColorStorage: ObservableObject {
    @Published var savedColors: [SavedColor] = []
    
    func saveColor(_ color: Color, hex: String) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let savedColor = SavedColor(
            hex: hex,
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            timestamp: Date()
        )
        
        savedColors.insert(savedColor, at: 0) // Add to beginning of list
    }
}

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var colorStorage = ColorStorage()
    @State private var showingColorsList = false
    @State private var showSavedMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                CameraPreview(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                VStack {
                    // Top navigation
                    HStack {
                        Spacer()
                        NavigationLink(destination: ColorsListView(colorStorage: colorStorage)) {
                            Text("Colors")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    
                    Spacer()
                    
                    // Color output display
                    VStack(spacing: 10) {
                        // Clickable color preview square
                        Button(action: {
                            colorStorage.saveColor(cameraManager.detectedColor, hex: cameraManager.hexColor)
                            showSavedMessage = true
                            
                            // Hide message after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSavedMessage = false
                            }
                        }) {
                            Rectangle()
                                .fill(cameraManager.detectedColor)
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        
                        // Hex color text
                        Text(cameraManager.hexColor)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, showSavedMessage ? 60 : 100)
                    
                    // "Color saved" message
                    if showSavedMessage {
                        Text("Color saved")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .padding(.bottom, 40)
                    }
                }
                
                // Center crosshair for targeting
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(8)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                cameraManager.startSession()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .animation(.easeInOut(duration: 0.3), value: showSavedMessage)
        }
    }
}

// MARK: - Colors List View
struct ColorsListView: View {
    @ObservedObject var colorStorage: ColorStorage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if colorStorage.savedColors.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No colors saved yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Go back to the camera and tap on colors to save them")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(colorStorage.savedColors) { savedColor in
                            ColorRowView(savedColor: savedColor)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Saved Colors")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Color Row View
struct ColorRowView: View {
    let savedColor: SavedColor
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Color preview
            Rectangle()
                .fill(savedColor.color)
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Color info
            VStack(alignment: .leading, spacing: 4) {
                Text(savedColor.hex)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(dateFormatter.string(from: savedColor.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var detectedColor: Color = .gray
    @Published var hexColor: String = "#808080"
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var updateTimer: Timer?
    private var currentColor: Color = .gray
    private var currentHex: String = "#808080"
    
    override init() {
        super.init()
        setupCamera()
        startColorUpdateTimer()
    }
    
    private func setupCamera() {
        // Request camera permission first
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { return }
            
            DispatchQueue.main.async {
                self.configureCameraSession()
            }
        }
    }
    
    private func configureCameraSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to access camera")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium
        
        // Remove existing inputs/outputs
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        startColorUpdateTimer()
    }
    
    func stopSession() {
        captureSession.stopRunning()
        stopColorUpdateTimer()
    }
    
    private func startColorUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.detectedColor = self.currentColor
                self.hexColor = self.currentHex
            }
        }
    }
    
    private func stopColorUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
        }
        return previewLayer!
    }
}

// MARK: - Camera Delegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        
        // Get center pixel
        let centerX = width / 2
        let centerY = height / 2
        let pixelOffset = centerY * bytesPerRow + centerX * 4
        
        let pixel = baseAddress.assumingMemoryBound(to: UInt8.self).advanced(by: pixelOffset)
        
        let blue = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let red = CGFloat(pixel[2]) / 255.0
        
        // Store current color values but don't update UI immediately
        let newColor = Color(red: red, green: green, blue: blue)
        let newHex = colorToHex(red: red, green: green, blue: blue)
        
        currentColor = newColor
        currentHex = newHex
    }
    
    private func colorToHex(red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        DispatchQueue.main.async {
            let previewLayer = cameraManager.getPreviewLayer()
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                layer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Preview with Test Image
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Test background image
            LinearGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Mock color output display
                VStack(spacing: 10) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    Text("#FF0000")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding(.bottom, 100)
            }
            
            // Center crosshair
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
