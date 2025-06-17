import SwiftUI

struct SecondPageView: View {
    // MARK: - State Variables
    // These @State variables track the values of our input elements
    @State private var textInput = ""           // Tracks text field input
    @State private var isToggleOn = false       // Tracks toggle switch state
    @State private var stepperValue = 5         // Tracks stepper value
    
    var body: some View {
        // ScrollView ensures all content is accessible even on smaller screens
        ScrollView {
            VStack(spacing: 40) {
                
                HeaderSection(
                    title: "Input Demo",
                    subtitle: "Text, toggles & steppers"
                )
                
                // MARK: - Navigation to Third Page
                NavigationLink(destination: ThirdPageView()) {
                    Text("Go to Picker Demo →")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30)
                
                // MARK: - Text Field Section
                TextFieldSection(textInput: $textInput)
                
                Divider() // Visual separator between sections
                
                // MARK: - Toggle Section
                ToggleSection(isToggleOn: $isToggleOn)
                
                Divider()
                
                // MARK: - Stepper Section
                StepperSection(stepperValue: $stepperValue)
                
                Spacer(minLength: 30)
                
                // MARK: - Reset Button
                InputResetButton(
                    textInput: $textInput,
                    isToggleOn: $isToggleOn,
                    stepperValue: $stepperValue
                )
                
            }
            .padding() // Add padding around entire VStack
            .padding(.top, 20) // Extra top margin
            .padding(.bottom, 30) // Extra bottom margin
        }
        .navigationTitle("Input Demo") // Navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Compact title style
        .background(
            // Dynamic background that changes based on toggle state
            LinearGradient(
                gradient: Gradient(colors: [
                    isToggleOn ? Color.green.opacity(0.1) : Color.gray.opacity(0.1),
                    Color.blue.opacity(Double(stepperValue) / 50.0) // Changes with stepper
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(.easeInOut(duration: 0.3), value: isToggleOn) // Animate background changes
        .animation(.easeInOut(duration: 0.3), value: stepperValue)
    }
}

// MARK: - Preview
struct SecondPageView_Previews: PreviewProvider {
    static var previews: some View {
        SecondPageView()
    }
}
