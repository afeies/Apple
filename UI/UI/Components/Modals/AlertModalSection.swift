import SwiftUI

struct AlertModalSection: View {
    // MARK: - Binding Property
    @Binding var showAlert: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("3. Alert Modal")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Description
            Text("Small centered popup")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // MARK: - Alert Modal Button
            Button(action: {
                showAlert = true
                HapticManager.shared.lightImpact()
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                    Text("Show Alert")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color.orange)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            
            // MARK: - Visual Indicator
            Image(systemName: "bell.fill")
                .font(.system(size: 30))
                .foregroundColor(.orange.opacity(0.6))
                .rotationEffect(.degrees(showAlert ? 15 : -15))
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showAlert)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct AlertModalSection_Previews: PreviewProvider {
    static var previews: some View {
        AlertModalSection(showAlert: .constant(false))
    }
}
