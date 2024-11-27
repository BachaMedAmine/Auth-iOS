//
//  UpdateCarView.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 27/11/2024.
//

import Foundation
import SwiftUI

struct UpdateCarView: View {
    @Binding var car: Car
    @State private var newMake: String = ""
    @State private var newModel: String = ""
    @State private var newYear: String = ""
    @State private var newMileage: String = ""
    @State private var selectedImage: UIImage? // State for the new image
    @State private var showPhotoPicker = false
    @State private var showCamera = false

    var onUpdate: (Car, UIImage?) -> Void // Callback with updated car details and optional image

    var body: some View {
        VStack {
            Text("Update Car Details")
                .font(.headline)
                .padding()

            // Input fields for car details
            Form {
                Section(header: Text("Car Details")) {
                    TextField("Make", text: $newMake)
                    TextField("Model", text: $newModel)
                    TextField("Year", text: $newYear)
                        .keyboardType(.numberPad)
                    TextField("Mileage", text: $newMileage)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Car Image")) {
                    // Display the selected or current image
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding()
                    } else if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                              let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .padding()
                            } else {
                                ProgressView()
                                    .frame(height: 200)
                            }
                        }
                    }

                    // Buttons for selecting an image
                    HStack {
                        Button("Select from Photos") {
                            showPhotoPicker = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Take a Photo") {
                            showCamera = true
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }

            // Update button
            Button(action: {
                // Create updated car object
                let updatedCar = Car(
                    id: car.id,
                    make: newMake.isEmpty ? car.make : newMake,
                    carModel: newModel.isEmpty ? car.carModel : newModel,
                    year: Int(newYear) ?? car.year,
                    mileage: Int(newMileage) ?? car.mileage,
                    owner: car.owner,
                    imageUrl: car.imageUrl // Keep the existing URL if no new image is uploaded
                )
                // Call the update callback with the updated details and selected image
                onUpdate(updatedCar, selectedImage)
            }) {
                Text("Update Car")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotosPickerView(selectedItem: .constant(nil), imageFromPicker: $selectedImage)
        }
        .fullScreenCover(isPresented: $showCamera) {
            AccessCameraView(selectedImage: $selectedImage)
        }
        .onAppear {
            // Pre-fill fields with existing car details
            newMake = car.make
            newModel = car.carModel
            newYear = String(car.year)
            newMileage = String(car.mileage)
        }
    }
}


