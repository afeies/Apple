import SwiftUI

struct FullScreenModalContent: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var progress: Double = 0.0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Covers entire screen including safe areas
            
            VStack(spacing: 40) {
                
                Spacer()
                
                // MARK: - Header
                VStack(spacing: 20) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Full Screen Modal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("This modal covers the entire screen and is perfect for immersive experiences, onboarding, or media viewing.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // MARK: - Interactive Demo
                VStack(spacing: 30) {
                    Text("Progress Demo")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Progress circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 10)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: progress)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 20) {
                        Button("Start") {
                            withAnimation {
                                progress = 1.0
                            }
                            HapticManager.shared.success()
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Reset") {
                            withAnimation {
                                progress = 0.0
                            }
                            HapticManager.shared.lightImpact()
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                // MARK: - Educational Info
                VStack(spacing: 15) {
                    Text("💡 Full Screen Modal Uses:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Onboarding tutorials")
                        Text("• Photo/video viewers")
                        Text("• Immersive experiences")
                        Text("• Settings that need focus")
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // MARK: - Close Button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Close Full Screen")
                    }
                    .font(.headline)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                }
                
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview
struct FullScreenModalContent_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenModalContent()
    }
}
