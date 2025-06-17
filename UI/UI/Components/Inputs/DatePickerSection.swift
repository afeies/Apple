import SwiftUI

struct DatePickerSection: View {
    // MARK: - Binding Property
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 15) {
            // Section title
            Text("2. Date Picker")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Display current selection in readable format
            Text("Selected Date:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(selectedDate, style: .date)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .animation(.easeInOut(duration: 0.2), value: selectedDate)
            
            // MARK: - DatePicker Component
            DatePicker(
                "Choose Date",              // Accessibility label
                selection: $selectedDate,   // Binding to our state variable
                displayedComponents: .date  // Only show date (not time)
            )
            .datePickerStyle(GraphicalDatePickerStyle()) // Calendar-style picker
            .padding(.horizontal, 20)
            .onChange(of: selectedDate) { newValue in
                // Called when date selection changes
                HapticManager.shared.selectionChanged()
                print("Date changed to: \(newValue)")
            }
            
            // MARK: - Additional Date Info
            VStack(spacing: 8) {
                // Show day of week
                Text("Day: \(dayOfWeek(selectedDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Show how many days from today
                Text("Days from today: \(daysFromToday(selectedDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedDate)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    // Get day of week from date
    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (Monday, Tuesday, etc.)
        return formatter.string(from: date)
    }
    
    // Calculate days difference from today
    private func daysFromToday(_ date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: today, to: selectedDay)
        return components.day ?? 0
    }
}

// MARK: - Preview
struct DatePickerSection_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerSection(selectedDate: .constant(Date()))
    }
}
