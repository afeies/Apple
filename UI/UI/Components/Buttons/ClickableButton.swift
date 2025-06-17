import SwiftUI

struct ClickableButtonSection: View {
    @Binding var clickCount: Int
    
    var body: some View {
        VStack(spacing: 15) {
            Text("1. Clickable Button")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Clicked \(clickCount) times")
                .font(.title2)
                .foregroundColor(.primary)
            
            Button(action: {
                clickCount += 1
                HapticManager.shared.mediumImpact()
            }) {
                Text("Tap Me!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding(.horizontal)
    }
}
