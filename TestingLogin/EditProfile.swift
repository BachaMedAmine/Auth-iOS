//
//  EditProfile.swift
//  TestingLogin
//
//  Created by Meriem Abid on 5/11/2024.
//

import SwiftUI

struct EditProfile: View {
    @State private var fullName: String = "" // User's full name
    @State private var showAlert = false // Flag to show success or error alerts
    @State private var alertMessage = "" // Message to display in the alert

    @Environment(\.dismiss) private var dismiss // Dismiss the view
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                
                // HStack for back button
                HStack {
                    Button(action: {
                        dismiss() // Dismiss the view
                    }, label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    })
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 10)
                
                Text("Edit Profile")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 10)
                
                VStack(spacing: 30) {
                    // Text field for full name
                    CustomTF(sfIcon: "person", hint: "Full Name", value: $fullName)
                        .padding(.horizontal, 20)
                    
                    // Button to update the profile
                    Button(action: {
                        updateProfile()
                    }) {
                        Text("Edit Profile")
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .disableWithOpacity(fullName.isEmpty) // Disable button if fullName is empty
                }
                .padding(.horizontal, 5)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 5)
            .padding(.top, 20)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Update Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func updateProfile() {
        // Call the network service to update the user's name
        NetworkService.shared.updateUserName(newName: fullName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    alertMessage = message // Show success message
                    showAlert = true
                case .failure(let error):
                    alertMessage = "Failed to update profile: \(error.localizedDescription)" // Show error message
                    showAlert = true
                }
            }
        }
    }
}
