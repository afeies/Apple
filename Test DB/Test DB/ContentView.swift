import SwiftUI
import CoreData
import CoreLocation
import UIKit

// MARK: - Core Data Model
// Add this to your .xcdatamodeld file:
// Entity: DataItem
// Attributes:
// - text: String
// - timestamp: Date
// - latitude: Double
// - longitude: Double
// - imageData: Binary Data (Optional)

// MARK: - Core Data Stack
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel") // Your .xcdatamodeld file name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
}

// MARK: - Data Item Entity Extension
extension DataItem {
    static func create(text: String, location: CLLocation?, image: UIImage?, context: NSManagedObjectContext) {
        let item = DataItem(context: context)
        item.text = text
        item.timestamp = Date()
        item.latitude = location?.coordinate.latitude ?? 0.0
        item.longitude = location?.coordinate.longitude ?? 0.0
        if let image = image {
            item.imageData = image.jpegData(compressionQuality: 0.8)
        }
    }
}

// MARK: - Add Item View
struct AddItemView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var locationManager = LocationManager()
    @State private var text = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                        }
                    }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .onTapGesture {
                            showingImagePicker = true
                        }
                } else {
                    Button("Select Image") {
                        showingImagePicker = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button("Add Item") {
                    addItem()
                }
                .padding()
                .background(text.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(text.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Add Item")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Item Added", isPresented: $showingAlert) {
                Button("OK") { }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }
    
    private func addItem() {
        DataItem.create(text: text, location: locationManager.location, image: selectedImage, context: context)
        PersistenceController.shared.save()
        
        // Reset form
        text = ""
        selectedImage = nil
        showingAlert = true
    }
}

// MARK: - Search View
struct SearchView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var searchText = ""
    @State private var searchResults: [DataItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search text", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onSubmit {
                        performSearch()
                    }
                
                Button("Search") {
                    performSearch()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                List(searchResults, id: \.objectID) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.text ?? "No text")
                            .font(.headline)
                        
                        Text("Date: \(item.timestamp ?? Date(), formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Location: \(item.latitude, specifier: "%.4f"), \(item.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let imageData = item.imageData,
                           let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private func performSearch() {
        let request: NSFetchRequest<DataItem> = DataItem.fetchRequest()
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DataItem.timestamp, ascending: false)]
        
        do {
            searchResults = try context.fetch(request)
        } catch {
            print("Search error: \(error)")
            searchResults = []
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some View {
        TabView {
            AddItemView()
                .tabItem {
                    Image(systemName: "plus")
                    Text("Add")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        }
        .environment(\.managedObjectContext, persistenceController.context)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
