import SwiftUI

struct StepperSection: View {
    // MARK: - Binding Property
    // @Binding allows this component to modify the stepper value in parent
    @Binding var stepperValue: Int
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("3. Stepper")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current stepper value with visual emphasis
            Text("\(stepperValue)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 80, height: 80)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: stepperValue)
            
            // MARK: - Stepper Component
            Stepper(
                "Value: \(stepperValue)", // Simplified label
                value: $stepperValue,     // Binding to our state variable
                in: 0...20,              // Range: minimum 0, maximum 20
                step: 1                  // Increment/decrement by 1
            ) { isEditing in
                // onEditingChanged callback
                if !isEditing {
                    HapticManager.shared.selectionChanged()
                }
            }
            .font(.title3)
            .padding(.horizontal, 20)
            
            // MARK: - Simple Progress Bar
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 8)
                .cornerRadius(4)
                .overlay(
                    HStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: CGFloat(stepperValue) / 20.0 * 200)
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.3), value: stepperValue)
                        Spacer()
                    }
                )
                .frame(width: 200)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct StepperSection_Previews: PreviewProvider {
    static var previews: some View {
        StepperSection(stepperValue: .constant(10))
    }
}
