import SwiftUI

struct PickerResetButton: View {
    // MARK: - Binding Properties
    // Multiple bindings to reset all picker elements at once
    @Binding var selectedColor: String
    @Binding var selectedDate: Date
    @Binding var pickerStyle: Int
    
    var body: some View {
        // MARK: - Reset Button
        Button("Reset All") {
            // Reset all values to their defaults
            selectedColor = "Blue"       // Reset color to default
            selectedDate = Date()        // Reset date to today
            pickerStyle = 0              // Reset picker style to wheel
            
            // Success haptic feedback for reset action
            HapticManager.shared.success()
            
            print("All picker values reset to defaults")
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
struct PickerResetButton_Previews: PreviewProvider {
    static var previews: some View {
        PickerResetButton(
            selectedColor: .constant("Purple"),
            selectedDate: .constant(Date()),
            pickerStyle: .constant(1)
        )
    }
}
