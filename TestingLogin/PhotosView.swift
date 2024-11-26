import SwiftUI
import PhotosUI

struct PhotosView: View {
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var sliderOffsetCamera: CGFloat = 0 // Offset pour le slider "Open Camera"
    @State private var sliderOffsetPhotos: CGFloat = 0 // Offset pour le slider "Select from Photos"
    @State private var sliderOffsetAnalyzeImage: CGFloat = 0 // Offset pour le slider "Select from Photos"
    @State private var navigateToHome = false // Déclenche la navigation vers HomePage
    @State private var selectedItem: PhotosPickerItem?
    @State private var cars: [Car] = [] // Liste des voitures ajoutées
    @State private var isLoading = false // Variable pour gérer l'état de chargement

    
    var body: some View {
           NavigationStack {
               ZStack {
                   // Background image
                   Image("Bugatti")
                       .resizable()
                       .scaledToFill()
                       .edgesIgnoringSafeArea(.all)

                   // Gradient overlay
                   LinearGradient(
                       gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                       startPoint: .top,
                       endPoint: .bottom
                   )
                   .edgesIgnoringSafeArea(.all)

                   VStack(spacing: 35) {
                       // Slider for opening the camera
                       SliderActionView(
                           label: "Open Camera",
                           sliderOffset: $sliderOffsetCamera,
                           action: {
                               logNavigation(from: "PhotosView", to: "Camera")
                               showCamera = true
                           }
                       )
                       .frame(width: 300, height: 60)

                       // Slider for selecting a photo from the gallery
                       SliderActionView(
                           label: "Select Photos",
                           sliderOffset: $sliderOffsetPhotos,
                           action: {
                               logNavigation(from: "PhotosView", to: "PhotoPicker")
                               showPhotoPicker = true
                           }
                       )
                       .frame(width: 300, height: 60)

                       // Slider for analyzing the selected image
                       SliderActionView(
                           label: isLoading ? "" : "Analyze Image",
                           sliderOffset: $sliderOffsetAnalyzeImage,
                           action: {
                               if let selectedImage = selectedImage {
                                   uploadImageToBackend(image: selectedImage) { details in
                                       DispatchQueue.main.async {
                                           CarManager.shared.cars.append(details)
                                           logNavigation(from: "PhotosView", to: "HomePage")
                                           navigateToHome = true
                                       }
                                   }
                               } else {
                                   print("No image selected. Please select an image before analyzing.")
                               }
                           }
                       )
                       .disabled(selectedImage == nil || isLoading)
                       .frame(width: 300, height: 60)
                   }
                   .padding(.horizontal, 20)
               }
               .navigationDestination(isPresented: $navigateToHome) {
                   HomePage()
                       .onAppear {
                           logNavigation(from: "PhotosView", to: "HomePage")
                       }
               }
           }
           .fullScreenCover(isPresented: $showCamera) {
               AccessCameraView(selectedImage: $selectedImage)
           }
           .sheet(isPresented: $showPhotoPicker) {
               PhotosPickerView(selectedItem: $selectedItem, imageFromPicker: $selectedImage)
           }
           .onChange(of: selectedItem) { newItem in
               Task {
                   if let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) {
                       selectedImage = uiImage
                   } else {
                       print("Failed to load the image")
                   }
               }
           }
       }
    
    // Fonction pour envoyer une image au backend
    func uploadImageToBackend(image: UIImage, completion: @escaping (Car) -> Void) {
        guard let url = URL(string: "http://localhost:3000/cars/upload-image") else {
            print("Invalid URL")
            return
        }

        guard let token = TokenManager.shared.getToken(for: TokenManager.accessTokenKey) else {
            print("No auth token found")
            return
        }

        print("Auth token:", token)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"car.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.8)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Upload error: \(error)")
                return
            }

            guard let responseData = responseData else {
                print("No response data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(CarResponse.self, from: responseData)
                if var carDetails = decodedResponse.car {
                    DispatchQueue.main.async {
                        // Add car to shared manager
                        CarManager.shared.cars.append(carDetails)
                        logNavigation(from: "PhotosView", to: "HomePage")

                        // Navigate to home page explicitly
                        navigateToHome = true
                    }
                } else {
                    print("Car details not found in response.")
                }
            } catch {
                print("Error decoding response: \(error)")
                if let responseString = String(data: responseData, encoding: .utf8) {
                                    print("Response data: \(responseString)")
                                }
            }
        }.resume()
    }


}


struct SliderActionView: View {
    let label: String
    @Binding var sliderOffset: CGFloat
    let action: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            // Fond du slider
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white.opacity(0.2)) // Ajustez la transparence pour plus de visibilité
                .frame(height: 60)

            // Slider dynamique
            RoundedRectangle(cornerRadius: 50)
                .fill(Color(red: 191/255, green: 229/255, blue: 72/255))
                .frame(width: max(150, sliderOffset + 60), height: 60) // Ajustez la largeur initiale
                .overlay(
                    HStack {
                        Text(label)
                            .foregroundColor(.black)
                            .bold()
                            .padding(.leading, 15)
                        Spacer()
                    }
                )

            // Icône flèche
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .padding(.trailing, 15)
                    .opacity(sliderOffset > 100 ? 1 : 0.5)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 0 {
                        sliderOffset = min(value.translation.width, 200) // Limite maximale de 200
                    }
                }
                .onEnded { value in
                    if sliderOffset > 100 {
                        action()
                    }
                    withAnimation {
                        sliderOffset = 0
                    }
                }
        )
    }
}

struct AccessCameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: AccessCameraView

        init(picker: AccessCameraView) {
            self.picker = picker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}

struct PhotosPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageFromPicker: UIImage?

    var body: some View {
        PhotosPicker("Select an image", selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        imageFromPicker = uiImage
                    } else {
                        print("Failed to load the image")
                    }
                }
            }
    }
}
