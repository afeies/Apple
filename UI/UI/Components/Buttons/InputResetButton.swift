import SwiftUI

struct InputResetButton: View {
    // MARK: - Binding Properties
    // Multiple bindings to reset all input elements at once
    @Binding var textInput: String
    @Binding var isToggleOn: Bool
    @Binding var stepperValue: Int
    
    var body: some View {
        // MARK: - Reset Button
        Button("Reset All") {
            // Reset all values to their defaults
            textInput = ""           // Clear text field
            isToggleOn = false       // Turn off toggle
            stepperValue = 5         // Reset stepper to middle value
            
            // Success haptic feedback for reset action
            HapticManager.shared.success()
        }
        .font(.headline)
        .foregroundColor(.red)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: 2)
        )
    }
}

// MARK: - Preview
struct InputResetButton_Previews: PreviewProvider {
    static var previews: some View {
        InputResetButton(
            textInput: .constant("Sample"),
            isToggleOn: .constant(true),
            stepperValue: .constant(10)
        )
    }
}
