import SwiftUI

struct SheetModalSection: View {
    // MARK: - Binding Properties
    @Binding var showSheetModal: Bool
    @Binding var modalResult: String
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("1. Sheet Modal")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Description
            Text("Slides up from bottom")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // MARK: - Sheet Modal Button
            Button(action: {
                showSheetModal = true
                HapticManager.shared.lightImpact()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.bottomhalf.inset.filled")
                        .font(.title2)
                    Text("Show Sheet")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            
            // MARK: - Visual Indicator
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue.opacity(0.6))
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: showSheetModal)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct SheetModalSection_Previews: PreviewProvider {
    static var previews: some View {
        SheetModalSection(
            showSheetModal: .constant(false),
            modalResult: .constant("")
        )
    }
}
