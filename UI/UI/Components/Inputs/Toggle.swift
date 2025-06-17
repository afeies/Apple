import SwiftUI

struct ToggleSection: View {
    // MARK: - Binding Property
    // @Binding connects this component to the parent's toggle state
    @Binding var isToggleOn: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("2. Toggle Switch")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current toggle state
            Text(isToggleOn ? "ON ✅" : "OFF ❌")
                .font(.title2)
                .foregroundColor(isToggleOn ? .green : .red)
                .animation(.easeInOut(duration: 0.2), value: isToggleOn)
            
            // MARK: - Toggle Component
            Toggle("Enable Feature", isOn: $isToggleOn)
                .font(.title3)
                .padding(.horizontal, 20)
                .toggleStyle(SwitchToggleStyle()) // iOS-style switch (default)
                .onChange(of: isToggleOn) { newValue in
                    // Different haptic feedback based on state
                    if newValue {
                        HapticManager.shared.success()
                    } else {
                        HapticManager.shared.lightImpact()
                    }
                }
            
            // MARK: - Visual Feedback
            // Icon that changes based on toggle state
            Image(systemName: isToggleOn ? "lightbulb.fill" : "lightbulb")
                .font(.system(size: 40))
                .foregroundColor(isToggleOn ? .yellow : .gray)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isToggleOn)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct ToggleSection_Previews: PreviewProvider {
    static var previews: some View {
        ToggleSection(isToggleOn: .constant(true))
    }
}
