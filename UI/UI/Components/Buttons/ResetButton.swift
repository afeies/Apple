import SwiftUI

struct ResetButton: View {
    @Binding var clickCount: Int
    @Binding var isHolding: Bool
    @Binding var sliderValue: Double
    
    var body: some View {
        VStack {
            Spacer()
            
            Button("Reset All") {
                clickCount = 0
                isHolding = false
                sliderValue = 50
                
                HapticManager.shared.success()
            }
            .font(.headline)
            .foregroundColor(.red)
            .padding(.bottom, 30)
        }
    }
}
