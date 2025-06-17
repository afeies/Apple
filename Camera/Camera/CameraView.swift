import SwiftUI
import AVFoundation
import UIKit

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
