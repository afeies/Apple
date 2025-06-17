import SwiftUI

struct TextFieldSection: View {
    // MARK: - Binding Property
    // @Binding allows this component to modify the parent's state
    @Binding var textInput: String
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("1. Text Field")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current text length
            Text("Characters: \(textInput.count)")
                .font(.title2)
                .foregroundColor(.primary)
            
            // MARK: - TextField Component
            TextField("Type something here...", text: $textInput)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Built-in styling
                .font(.title3)
                .padding(.horizontal, 20)
                .onSubmit {
                    // Called when user presses "return" key
                    HapticManager.shared.selectionChanged()
                }
            
            // MARK: - Visual Feedback
            // Rectangle that grows/shrinks based on text length
            if !textInput.isEmpty {
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 8)
                    .frame(width: CGFloat(textInput.count) * 10) // Width based on character count
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.2), value: textInput.count)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct TextFieldSection_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldSection(textInput: .constant("Sample text"))
    }
}
