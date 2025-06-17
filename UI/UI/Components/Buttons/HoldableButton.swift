import SwiftUI

struct HoldableButtonSection: View {
    @Binding var isHolding: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text("2. Holdable Button")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(isHolding ? "Holding! 🔥" : "Not holding")
                .font(.title2)
                .foregroundColor(isHolding ? .orange : .primary)
                .animation(.easeInOut(duration: 0.2), value: isHolding)
            
            Rectangle()
                .fill(isHolding ? Color.orange : Color.green)
                .frame(height: 50)
                .cornerRadius(10)
                .shadow(radius: 3)
                .scaleEffect(isHolding ? 1.1 : 1.0)
                .overlay(
                    Text(isHolding ? "Release Me!" : "Hold Me!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                )
                .padding(.horizontal, 30)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isHolding {
                                isHolding = true
                                HapticManager.shared.heavyImpact()
                            }
                        }
                        .onEnded { _ in
                            isHolding = false
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHolding)
        }
    }
}
