import SwiftUI

struct SliderSection: View {
    @Binding var sliderValue: Double
    
    var body: some View {
        VStack(spacing: 15) {
            Text("3. Interactive Slider")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Value: \(Int(sliderValue))")
                .font(.title2)
                .foregroundColor(.primary)
            
            Slider(
                value: $sliderValue,
                in: 0...100,
                step: 1
            ) {
                Text("Color Intensity")
            } minimumValueLabel: {
                Text("0")
                    .font(.caption)
            } maximumValueLabel: {
                Text("100")
                    .font(.caption)
            } onEditingChanged: { editing in
                if !editing {
                    HapticManager.shared.selectionChanged()
                }
            }
            .accentColor(.purple)
            .padding(.horizontal, 20)
            
            Rectangle()
                .fill(Color.purple)
                .opacity(sliderValue / 100.0)
                .frame(height: 60)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.1), value: sliderValue)
        }
        .padding(.horizontal)
    }
}
