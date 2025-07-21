//
//  ContentView.swift
//  VPHello
//
//  Created by Alex Feies on 7/11/25.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @State private var rectangles: [RectangleData] = []
    @State private var windowSize: CGSize = CGSize(width: 400, height: 600) // Default size
    @Environment(\.openWindow) private var openWindow
    @Binding var windowCount: Int
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var selectedNoteID: UUID? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to VPHello!")
                .font(.largeTitle)
                .padding()
            
            HStack(spacing: 15) {
                Button("Add Note") {
                    let centerX = windowSize.width / 2
                    let centerY = windowSize.height / 2
                    let newRectangle = RectangleData(
                        id: UUID(),
                        position: CGPoint(x: centerX, y: centerY),
                        size: CGSize(width: 200, height: 150)
                    )
                    rectangles.append(newRectangle)
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("New Window") {
                    openWindow(id: "noteWindow")
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Voice Recognition Section
            VStack(spacing: 15) {
                Button(isRecording ? "Stop Recording" : "Tap to Speak") {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }
                .font(.headline)
                .padding()
                .background(isRecording ? Color.red : Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if !recognizedText.isEmpty {
                    Text("Recognized Text:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(recognizedText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            ScrollView {
                ZStack {
                    ForEach(rectangles) { rectangle in
                        Rectangle()
                            .fill(selectedNoteID == rectangle.id ? Color.gray : Color.white)
                            .frame(width: rectangle.size.width, height: rectangle.size.height)
                            .position(rectangle.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let index = rectangles.firstIndex(where: { $0.id == rectangle.id }) {
                                            rectangles[index].position = value.location
                                            selectedNoteID = rectangle.id // Select on drag
                                        }
                                    }
                            )
                            .onTapGesture {
                                selectedNoteID = rectangle.id
                            }
                    }
                }
                .frame(minHeight: 600)
            }
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    windowSize = geometry.size
                }
            })
            
            Spacer()
        }
        .padding()
    }
    
    private func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        // Reset audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Failed to create recognition request")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Failed to start audio engine: \(error)")
            stopRecording()
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}

struct NoteWindowView: View {
    let windowID: Int
    @State private var rectangles: [RectangleData] = []
    @State private var windowSize: CGSize = CGSize(width: 400, height: 600)
    @State private var selectedNoteID: UUID? = nil
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Window")
                .font(.largeTitle)
                .padding()
            
            HStack(spacing: 15) {
                Button("Add Note") {
                    let centerX = windowSize.width / 2
                    let centerY = windowSize.height / 2
                    let newRectangle = RectangleData(
                        id: UUID(),
                        position: CGPoint(x: centerX, y: centerY),
                        size: CGSize(width: 200, height: 150)
                    )
                    rectangles.append(newRectangle)
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("New Window") {
                    openWindow(id: "noteWindow")
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            ScrollView {
                ZStack {
                    ForEach(rectangles) { rectangle in
                        Rectangle()
                            .fill(selectedNoteID == rectangle.id ? Color.gray : Color.white)
                            .frame(width: rectangle.size.width, height: rectangle.size.height)
                            .position(rectangle.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let index = rectangles.firstIndex(where: { $0.id == rectangle.id }) {
                                            rectangles[index].position = value.location
                                            selectedNoteID = rectangle.id // Select on drag
                                        }
                                    }
                            )
                            .onTapGesture {
                                selectedNoteID = rectangle.id
                            }
                    }
                }
                .frame(minHeight: 600)
            }
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    windowSize = geometry.size
                }
            })
            
            Spacer()
        }
        .padding()
    }
}

struct RectangleData: Identifiable {
    let id: UUID
    var position: CGPoint
    var size: CGSize
}

#Preview(windowStyle: .automatic) {
    ContentView(windowCount: .constant(1))
}
