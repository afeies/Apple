import SwiftUI

struct ThirdPageView: View {
    // MARK: - State Variables
    // These @State variables track the values of our picker elements
    @State private var selectedColor = "Blue"           // Tracks picker selection
    @State private var selectedDate = Date()            // Tracks date picker selection
    @State private var pickerStyle = 0                  // Tracks picker style demo
    
    // Options for the color picker
    private let colorOptions = ["Red", "Blue", "Green", "Purple", "Orange"]
    private let styleOptions = ["Wheel", "Segmented", "Menu"]
    
    var body: some View {
        // ScrollView ensures all content is accessible even on smaller screens
        ScrollView {
            VStack(spacing: 40) {
                
                HeaderSection(
                    title: "Picker Demo",
                    subtitle: "Choose options & dates"
                )
                
                // MARK: - Navigation to Fourth Page
                NavigationLink(destination: FourthPageView()) {
                    Text("Go to Modal Demo →")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30)
                
                // MARK: - Color Picker Section
                ColorPickerSection(
                    selectedColor: $selectedColor,
                    colorOptions: colorOptions
                )
                
                Divider() // Visual separator between sections
                
                // MARK: - Date Picker Section
                DatePickerSection(selectedDate: $selectedDate)
                
                Divider()
                
                // MARK: - Picker Style Demo Section
                PickerStyleSection(
                    pickerStyle: $pickerStyle,
                    styleOptions: styleOptions
                )
                
                Spacer(minLength: 30)
                
                // MARK: - Reset Button
                PickerResetButton(
                    selectedColor: $selectedColor,
                    selectedDate: $selectedDate,
                    pickerStyle: $pickerStyle
                )
                
            }
            .padding()
            .padding(.top, 20) // Extra top margin
            .padding(.bottom, 30) // Extra bottom margin
        }
        .background(
            // Dynamic background that changes based on selected color
            LinearGradient(
                gradient: Gradient(colors: [
                    colorForSelection(selectedColor).opacity(0.1),
                    colorForSelection(selectedColor).opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .animation(.easeInOut(duration: 0.3), value: selectedColor)
        .navigationTitle("Picker Demo") // Navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Compact title style
    }
    
    // MARK: - Helper Function
    // Convert string color names to SwiftUI Colors
    private func colorForSelection(_ colorName: String) -> Color {
        switch colorName {
        case "Red": return .red
        case "Blue": return .blue
        case "Green": return .green
        case "Purple": return .purple
        case "Orange": return .orange
        default: return .blue
        }
    }
}

// MARK: - Preview
struct ThirdPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ThirdPageView()
        }
    }
}
