//
//  ChangePassword.swift
//  TestingLogin
//
//  Created by Meriem Abid on 5/11/2024.
//

import SwiftUI

struct ChangePassword: View {
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var errorMessage: String? // For displaying errors
    @State private var isLoading: Bool = false // Loading state
    @State private var showOldPassword: Bool = false // Toggle for old password visibility
    @State private var showNewPassword: Bool = false // Toggle for new password visibility
    @State private var showConfirmNewPassword: Bool = false // Toggle for confirm password visibility

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center) {
                // Back button
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    })
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 10)

                Text("Change Password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 10)

                VStack(spacing: 30) {
                    PasswordField(hint: "Old Password", value: $oldPassword, showText: $showOldPassword)
                        .padding(.horizontal, 20)

                    PasswordField(hint: "New Password", value: $newPassword, showText: $showNewPassword)
                        .padding(.horizontal, 20)

                    PasswordField(hint: "Confirm Password", value: $confirmNewPassword, showText: $showConfirmNewPassword)
                        .padding(.horizontal, 20)

                    // Change Password Button
                    Button(action: {
                        changePassword()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Change Password")
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .disableWithOpacity(
                        oldPassword.isEmpty ||
                        newPassword.isEmpty ||
                        confirmNewPassword.isEmpty
                    )
                }
                .padding(.horizontal, 5)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 5)
            .padding(.top, 20)

            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    private func changePassword() {
        guard newPassword == confirmNewPassword else {
            errorMessage = "New password and confirmation do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        NetworkService.shared.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    dismiss() // Close the ChangePassword view
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PasswordField: View {
    let hint: String
    @Binding var value: String
    @Binding var showText: Bool

    var body: some View {
        HStack {
            if showText {
                TextField(hint, text: $value)
                    .textContentType(.password)
            } else {
                SecureField(hint, text: $value)
                    .textContentType(.password)
            }
            Button(action: {
                showText.toggle()
            }) {
                Image(systemName: showText ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword()
            .preferredColorScheme(.light) // Light mode preview
        
        ChangePassword()
            .preferredColorScheme(.dark) // Dark mode preview
    }
}
