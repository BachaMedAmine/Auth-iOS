//
//  OTPView.swift
//  TestingLogin
//
//  Created by Meriem Abid on 4/11/2024.
//

import SwiftUI

struct OTPView: View {
    @Binding var otpText: String
    @State private var showResetView = false // Add this line to handle the reset view state
    @Binding var activeSheet: ActiveSheet?
    
    // Permet de renvoyer la vue actuelle en arrière-plan
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Bouton pour revenir en arrière
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.gray)
            })
            .padding(.top, 10)
            
            Text("Enter OTP")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)
            
            Text("A 6-digit code has been sent to your Email ID.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {
                
                // Pass the showResetView binding here
                OTPVerificationView(otpText: $otpText, showResetView: $showResetView, activeSheet: $activeSheet)

                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("Send Link")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(otpText.isEmpty) // Désactive le bouton si `otpText` est vide
                .opacity(otpText.isEmpty ? 0.5 : 1) // Réduit l'opacité si `otpText` est vide
            }
        }
        .padding()
    }
}
