import SwiftUI

struct ColorPickerSection: View {
    // MARK: - Binding Properties
    @Binding var selectedColor: String
    let colorOptions: [String]
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("1. Picker")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current selection
            Text("Selected: \(selectedColor)")
                .font(.title2)
                .foregroundColor(colorForSelection(selectedColor))
                .fontWeight(.semibold)
                .animation(.easeInOut(duration: 0.2), value: selectedColor)
            
            // MARK: - Picker Component (Segmented Style)
            Picker("Choose Color", selection: $selectedColor) {
                // ForEach creates picker options from our array
                ForEach(colorOptions, id: \.self) { color in
                    Text(color)
                        .tag(color) // Tag identifies which option was selected
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // iOS segmented control style
            .padding(.horizontal, 20)
            .onChange(of: selectedColor) { newValue in
                // Called when selection changes
                HapticManager.shared.selectionChanged()
                print("Color changed to: \(newValue)")
            }
            
            // MARK: - Visual Feedback
            // Circle that changes color based on selection
            Circle()
                .fill(colorForSelection(selectedColor))
                .frame(width: 60, height: 60)
                .shadow(radius: 5)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedColor)
        }
        .padding(.horizontal)
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
struct ColorPickerSection_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerSection(
            selectedColor: .constant("Blue"),
            colorOptions: ["Red", "Blue", "Green", "Purple", "Orange"]
        )
    }
}
