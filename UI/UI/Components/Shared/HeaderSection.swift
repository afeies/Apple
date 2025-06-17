import SwiftUI

struct HeaderSection: View {
    // MARK: - Properties
    // Make the header flexible to work on multiple pages
    let title: String
    let subtitle: String
    
    // MARK: - Initializer
    // Default values for backward compatibility with existing ContentView
    init(title: String = "UI Elements Demo", subtitle: String = "Learn how buttons and sliders work!") {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack {
            // Main title - responsive and clean
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .multilineTextAlignment(.center) // Center if title wraps
            
            // Subtitle with helpful description
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview
struct HeaderSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Preview with default values
            HeaderSection()
            
            Divider()
            
            // Preview with custom values
            HeaderSection(
                title: "Custom Title",
                subtitle: "Custom subtitle text"
            )
        }
    }
}
