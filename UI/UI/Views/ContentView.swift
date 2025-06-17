import SwiftUI

struct ContentView: View {
    // MARK: - State Variables
    // These track the state of interactive elements on page 1
    @State private var clickCount = 0
    @State private var isHolding = false
    @State private var sliderValue: Double = 50
    
    var body: some View {
        // MARK: - Navigation Container
        // NavigationView enables navigation between pages
        NavigationView {
            // ScrollView ensures all content is accessible even on smaller screens
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Header Section
                    HeaderSection()
                    
                    // MARK: - Navigation to Second Page
                    NavigationLink(destination: SecondPageView()) {
                        Text("Go to Input Elements →")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    // MARK: - Interactive Elements (Page 1)
                    ClickableButtonSection(clickCount: $clickCount)
                    
                    Divider()
                    
                    HoldableButtonSection(isHolding: $isHolding)
                    
                    Divider()
                    
                    SliderSection(sliderValue: $sliderValue)
                    
                    Spacer(minLength: 30)
                    
                    // MARK: - Reset Button
                    ResetButton(
                        clickCount: $clickCount,
                        isHolding: $isHolding,
                        sliderValue: $sliderValue
                    )
                    
                }
                .padding()
                .padding(.top, 20) // Extra top margin
                .padding(.bottom, 30) // Extra bottom margin
            }
            .background(
                // Dynamic background that changes with slider
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(sliderValue / 500.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .animation(.easeInOut(duration: 0.3), value: sliderValue)
            .navigationTitle("UI Demo") // Navigation bar title
            .navigationBarTitleDisplayMode(.inline) // Compact title style
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
