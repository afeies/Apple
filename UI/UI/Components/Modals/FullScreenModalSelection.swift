import SwiftUI

struct FullScreenModalSection: View {
    // MARK: - Binding Property
    @Binding var showFullScreenModal: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("2. Full Screen Modal")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Description
            Text("Covers entire screen")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // MARK: - Full Screen Modal Button
            Button(action: {
                showFullScreenModal = true
                HapticManager.shared.mediumImpact()
            }) {
                HStack {
                    Image(systemName: "rectangle.fill")
                        .font(.title2)
                    Text("Show Full Screen")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color.purple)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            
            // MARK: - Visual Indicator
            Image(systemName: "viewfinder")
                .font(.system(size: 30))
                .foregroundColor(.purple.opacity(0.6))
                .scaleEffect(showFullScreenModal ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showFullScreenModal)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct FullScreenModalSection_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenModalSection(showFullScreenModal: .constant(false))
    }
}
