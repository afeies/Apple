import SwiftUI

struct PickerStyleSection: View {
    // MARK: - Binding Properties
    @Binding var pickerStyle: Int
    let styleOptions: [String]
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("3. Picker Styles")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current style
            Text("Current Style: \(styleOptions[pickerStyle])")
                .font(.title3)
                .foregroundColor(.primary)
                .animation(.easeInOut(duration: 0.2), value: pickerStyle)
            
            // MARK: - Different Picker Styles Demo
            VStack(spacing: 20) {
                
                // Wheel Style Picker
                if pickerStyle == 0 {
                    Text("Wheel Style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Wheel Style", selection: $pickerStyle) {
                        ForEach(0..<styleOptions.count, id: \.self) { index in
                            Text(styleOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle()) // iOS wheel picker
                    .frame(height: 120)
                    .clipped()
                }
                
                // Segmented Style Picker
                if pickerStyle == 1 {
                    Text("Segmented Style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Segmented Style", selection: $pickerStyle) {
                        ForEach(0..<styleOptions.count, id: \.self) { index in
                            Text(styleOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Segmented control
                }
                
                // Menu Style Picker
                if pickerStyle == 2 {
                    Text("Menu Style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Menu Style", selection: $pickerStyle) {
                        ForEach(0..<styleOptions.count, id: \.self) { index in
                            Text(styleOptions[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Dropdown menu
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Style switcher buttons
                HStack(spacing: 15) {
                    ForEach(0..<styleOptions.count, id: \.self) { index in
                        Button(styleOptions[index]) {
                            pickerStyle = index
                            HapticManager.shared.lightImpact()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(pickerStyle == index ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(pickerStyle == index ? .white : .primary)
                        .cornerRadius(6)
                        .animation(.easeInOut(duration: 0.2), value: pickerStyle)
                    }
                }
            }
            .padding(.horizontal, 20)
            .onChange(of: pickerStyle) { newValue in
                // Called when picker style changes
                HapticManager.shared.selectionChanged()
                print("Picker style changed to: \(styleOptions[newValue])")
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct PickerStyleSection_Previews: PreviewProvider {
    static var previews: some View {
        PickerStyleSection(
            pickerStyle: .constant(0),
            styleOptions: ["Wheel", "Segmented", "Menu"]
        )
    }
}
