import SwiftUI

struct ModalResetButton: View {
    // MARK: - Binding Property
    @Binding var modalResult: String
    
    var body: some View {
        // MARK: - Reset Button
        Button("Clear Results") {
            // Clear modal results
            modalResult = ""
            
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
        .opacity(modalResult.isEmpty ? 0.5 : 1.0) // Dim when no results
        .disabled(modalResult.isEmpty) // Disable when no results to clear
    }
}

// MARK: - Preview
struct ModalResetButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModalResetButton(modalResult: .constant("Some result"))
            ModalResetButton(modalResult: .constant(""))
        }
    }
}
