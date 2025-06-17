import SwiftUI

struct SheetModalContent: View {
    // MARK: - Properties
    @Binding var modalResult: String
    @Environment(\.dismiss) private var dismiss  // Modern way to dismiss modal
    @State private var textInput = ""            // Local state for text input
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // MARK: - Modal Header
                VStack(spacing: 15) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Sheet Modal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This modal slides up from the bottom. You can interact with it and pass data back to the main view.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // MARK: - Interactive Content
                VStack(spacing: 20) {
                    Text("Enter some text:")
                        .font(.headline)
                    
                    TextField("Type something...", text: $textInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                    
                    Button("Save & Close") {
                        modalResult = "Sheet: \(textInput.isEmpty ? "No text entered" : textInput)"
                        HapticManager.shared.success()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // MARK: - Educational Info
                VStack(spacing: 10) {
                    Text("💡 Sheet Modal Features:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("• Slides up from bottom")
                        Text("• Can be dismissed by swiping down")
                        Text("• Perfect for forms and details")
                        Text("• Maintains context with main app")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
            }
            .navigationTitle("Sheet Example")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    modalResult = "Sheet: Cancelled"
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Preview
struct SheetModalContent_Previews: PreviewProvider {
    static var previews: some View {
        SheetModalContent(modalResult: .constant(""))
    }
}
