import SwiftUI

struct ActionSheetModalSection: View {
    // MARK: - Binding Property
    @Binding var showActionSheet: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("4. Action Sheet")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Description
            Text("Multiple action buttons")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // MARK: - Action Sheet Modal Button
            Button(action: {
                showActionSheet = true
                HapticManager.shared.lightImpact()
            }) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                    Text("Show Actions")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            
            // MARK: - Visual Indicator
            Image(systemName: "line.3.horizontal.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.green.opacity(0.6))
                .offset(y: showActionSheet ? -5 : 5)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showActionSheet)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct ActionSheetModalSection_Previews: PreviewProvider {
    static var previews: some View {
        ActionSheetModalSection(showActionSheet: .constant(false))
    }
}
