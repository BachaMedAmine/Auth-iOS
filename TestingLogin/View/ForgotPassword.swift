//
//  ForgotPassword.swift
//  TestingLogin
//
//  Created by Meriem Abid on 4/11/2024.
//

import SwiftUI

struct ForgotPassword: View {
    @Binding var showResetView: Bool
    @State private var emailID: String = ""
    @State private var askOTP: Bool = false
    @State private var otpText: String = ""
    @State private var message: String?
    @State private var error: String?
    @State private var showOTPView = false
    @State private var email: String = ""
    @Binding var activeSheet: ActiveSheet?
    
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 20) // Ajustez la largeur du décalage selon vos besoins
            
            VStack(alignment: .leading, spacing: 30, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundStyle(.gray)
                })
                .padding(.top, 10)
                
                Text("Forgot Password?")
                    .font(.largeTitle.bold())
                    .fontWeight(.heavy)
                    .padding(.top, 5)
                
                Text("Please enter your Email ID so that we can send the reset link.")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .padding(.top, -5)
                
                VStack(spacing: 25) {
                    CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                    
                    if let message = message {
                        Text(message)
                            .foregroundColor(.green)
                            .padding()
                    }

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        Task {
                            sendForgotPasswordRequest()
                            askOTP.toggle()}
                        }) {
                            
                        
                        HStack {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Send OTP")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) // Couleur du texte
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                            }
                            // Couleur de l'icône
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255)) // Couleur de fond
                        .cornerRadius(10) // Arrondi des bords
                    }
                    .padding(.horizontal)
                    .disableWithOpacity(emailID.isEmpty)
                    .sheet(isPresented: $askOTP) {
                        OTPVerificationView(otpText: $otpText, showResetView: $showResetView, activeSheet: $activeSheet)
                        
                            .presentationDetents([.height(350)])
                            .presentationCornerRadius(20)
                    }
                }
            })
        }
    }
   func sendForgotPasswordRequest() {
        isLoading = true
        NetworkService.shared.forgotPassword(email: emailID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let msg):
                    self.message = msg
                    self.askOTP = true
                    self.activeSheet = .otpVerification
                case .failure(let err):
                    self.error = err.localizedDescription
                }
            }
        }
    }
    
    
}
