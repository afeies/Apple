import SwiftUI

struct FourthPageView: View {
    // MARK: - State Variables
    // These @State variables control different modal presentations
    @State private var showSheetModal = false       // Controls sheet modal
    @State private var showFullScreenModal = false  // Controls full screen modal
    @State private var showAlert = false            // Controls alert modal
    @State private var showActionSheet = false      // Controls action sheet modal
    @State private var modalResult = ""             // Stores result from modals
    
    var body: some View {
        // ScrollView ensures all content is accessible even on smaller screens
        ScrollView {
            VStack(spacing: 40) {
                
                HeaderSection(
                    title: "Modal Demo",
                    subtitle: "Pop-ups, sheets & alerts"
                )
                
                Spacer(minLength: 30)
                
                // MARK: - Sheet Modal Section
                SheetModalSection(
                    showSheetModal: $showSheetModal,
                    modalResult: $modalResult
                )
                
                Divider() // Visual separator between sections
                
                // MARK: - Full Screen Modal Section
                FullScreenModalSection(showFullScreenModal: $showFullScreenModal)
                
                Divider()
                
                // MARK: - Alert Modal Section
                AlertModalSection(showAlert: $showAlert)
                
                Divider()
                
                // MARK: - Action Sheet Modal Section
                ActionSheetModalSection(showActionSheet: $showActionSheet)
                
                Spacer(minLength: 30)
                
                // MARK: - Modal Result Display
                if !modalResult.isEmpty {
                    VStack(spacing: 10) {
                        Text("Modal Result:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(modalResult)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Reset Button
                ModalResetButton(modalResult: $modalResult)
                
            }
            .padding()
            .padding(.top, 20) // Extra top margin
            .padding(.bottom, 30) // Extra bottom margin
        }
        .background(
            // Simple background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Modal Demo") // Navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Compact title style
        
        // MARK: - Modal Presentations
        .sheet(isPresented: $showSheetModal) {
            SheetModalContent(modalResult: $modalResult)
        }
        .fullScreenCover(isPresented: $showFullScreenModal) {
            FullScreenModalContent()
        }
        .alert("Alert Example", isPresented: $showAlert) {
            Button("OK") {
                modalResult = "Alert: OK pressed"
                HapticManager.shared.success()
            }
            Button("Cancel", role: .cancel) {
                modalResult = "Alert: Cancelled"
                HapticManager.shared.lightImpact()
            }
        } message: {
            Text("This is an alert modal. Choose an option.")
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Action Sheet"),
                message: Text("Choose an action"),
                buttons: [
                    .default(Text("Option 1")) {
                        modalResult = "Action Sheet: Option 1"
                        HapticManager.shared.selectionChanged()
                    },
                    .default(Text("Option 2")) {
                        modalResult = "Action Sheet: Option 2"
                        HapticManager.shared.selectionChanged()
                    },
                    .destructive(Text("Delete")) {
                        modalResult = "Action Sheet: Delete"
                        HapticManager.shared.heavyImpact()
                    },
                    .cancel {
                        modalResult = "Action Sheet: Cancelled"
                    }
                ]
            )
        }
    }
}

// MARK: - Preview
struct FourthPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FourthPageView()
        }
    }
}
