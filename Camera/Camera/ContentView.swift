import SwiftUI
import UIKit
import CoreData
import Speech

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var analysisResult = "Press Capture to analyze an image"
    @State private var isProcessing = false
    @State private var showingSearchView = false
    @State private var showingVoiceSearchView = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false
    @State private var transcribedText = ""
    
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
            
            // Search Database Buttons
            VStack(spacing: 12) {
                // Text Search Button
                Button(action: {
                    showingSearchView = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        Text("Search Database with Text")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Voice Search Button
                Button(action: {
                    showingVoiceSearchView = true
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                        Text("Search Database with Voice")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .padding(.top)
        .sheet(isPresented: $showingSearchView) {
            SearchView()
        }
        .sheet(isPresented: $showingVoiceSearchView) {
            VoiceSearchView()
        }
        .onAppear {
            locationManager.requestLocationPermission()
            requestSpeechPermission()
        }
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
        
        guard let url = URL(string: "http://192.168.68.50:8080/v1/chat/completions") else {
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
                        
                        // Save to Core Data
                        self.saveToDatabase(image: image, analysis: content)
                        
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
    
    private func saveToDatabase(image: UIImage, analysis: String) {
        let gpsString = locationManager.getCurrentLocationString()
        
        let _ = coreDataManager.createPhotoEntry(
            text: analysis,
            gps: gpsString,
            image: image.jpegData(compressionQuality: 0.8)
        )
    }
    
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                // Handle authorization status if needed
            }
        }
    }
}

struct VoiceSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var speechRecognizer: SFSpeechRecognizer?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false
    @State private var transcribedText = ""
    @State private var searchResults: [PhotoEntry] = []
    @State private var isSearching = false
    @State private var showingSearchResults = false
    @State private var speechAuthStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Microphone Icon
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .font(.system(size: 80))
                    .foregroundColor(isListening ? .red : .purple)
                    .scaleEffect(isListening ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isListening)
                
                // Status Text
                if speechAuthStatus == .denied || speechAuthStatus == .restricted {
                    Text("Speech recognition access denied. Please enable it in Settings.")
                        .font(.title2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text(isListening ? "Listening..." : "Tap to start voice search")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                
                // Transcribed Text Display
                if !transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You said:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(transcribedText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Search Results Count
                if isSearching {
                    Text("Searching...")
                        .font(.headline)
                        .foregroundColor(.blue)
                } else if !transcribedText.isEmpty && searchResults.isEmpty && !isSearching {
                    Text("Found no results")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 16) {
                    // Start/Stop Listening Button
                    if speechAuthStatus == .authorized {
                        Button(action: {
                            if isListening {
                                stopListening()
                            } else {
                                startListening()
                            }
                        }) {
                            HStack {
                                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                                    .font(.title2)
                                Text(isListening ? "Stop Listening" : "Start Listening")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isListening ? Color.red : Color.purple)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    } else {
                        Button(action: {
                            requestSpeechPermission()
                        }) {
                            HStack {
                                Image(systemName: "mic.slash")
                                    .font(.title2)
                                Text("Enable Speech Recognition")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Search Button
                    if !transcribedText.isEmpty {
                        Button(action: {
                            performVoiceSearch()
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                Text("Search Database")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .disabled(isSearching)
                    }
                }
            }
            .navigationTitle("Voice Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        stopListening()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSearchResults) {
            VoiceSearchResultsView(searchResults: searchResults)
        }
        .onAppear {
            setupSpeechRecognizer()
            requestSpeechPermission()
        }
        .onDisappear {
            stopListening()
        }
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = nil
    }
    
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.speechAuthStatus = status
            }
        }
    }
    
    private func startListening() {
        guard !isListening,
              speechAuthStatus == .authorized,
              let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            print("Speech recognition not available")
            return
        }
        
        // Reset transcribed text
        transcribedText = ""
        
        // Stop any existing audio session
        stopListening()
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        // Create and configure recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let error = error {
                print("Recognition error: \(error)")
                DispatchQueue.main.async {
                    self.stopListening()
                }
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.stopListening()
                    }
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Remove any existing tap
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("Failed to start audio engine: \(error)")
            stopListening()
        }
    }
    
    private func stopListening() {
        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset listening state
        isListening = false
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func performVoiceSearch() {
        guard !transcribedText.isEmpty else { 
            print("Transcribed text is empty")
            return 
        }
        
        print("Starting voice search with text: '\(transcribedText)'")
        isSearching = true
        
        // Perform search on main queue since we're already in a SwiftUI view
        let request: NSFetchRequest<PhotoEntry> = PhotoEntry.fetchRequest()
        let textPredicate = NSPredicate(format: "text CONTAINS[cd] %@", transcribedText)
        request.predicate = textPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PhotoEntry.timestamp, ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            print("Found \(results.count) results for search: '\(transcribedText)'")
            searchResults = results
            isSearching = false
            
            // Force UI update
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
                
                // Automatically show results if any found
                if !results.isEmpty {
                    self.showingSearchResults = true
                }
            }
        } catch {
            print("Error searching: \(error)")
            searchResults = []
            isSearching = false
            
            DispatchQueue.main.async {
                self.searchResults = []
                self.isSearching = false
            }
        }
    }
}

struct VoiceSearchResultsView: View {
    let searchResults: [PhotoEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEntry: PhotoEntry?
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Voice Search Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetailView) {
            if let entry = selectedEntry {
                PhotoEntryDetailView(entry: entry)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
