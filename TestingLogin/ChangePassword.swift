//
//  ChangePassword.swift
//  TestingLogin
//
//  Created by Meriem Abid on 5/11/2024.
//

import SwiftUI

struct ChangePassword: View {
    @State private var password: String = ""
    @State private var confirmpassword: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                
                // HStack pour aligner le bouton de retour à gauche
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    })
                    Spacer() // Pousse le bouton vers la gauche
                }
                .padding(.leading)
                .padding(.top, 10) // Marge en haut
                
                
                Text("Change Password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 10) // Petite marge en haut pour le titre
                
                VStack(spacing: 30) {
                    // Champs de texte avec marge horizontale
                    CustomTF(sfIcon: "lock", hint: "Old Password", value: $password)
                        .padding(.horizontal, 20)
                    
                    CustomTF(sfIcon: "lock", hint: "New Password", value: $password)
                        .padding(.horizontal, 20)
                    
                    CustomTF(sfIcon: "lock.shield", hint: "Confirm Password", value: $confirmpassword)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Action pour changer le mot de passe
                    }) {
                        Text("Change Password")
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .disableWithOpacity(password.isEmpty || confirmpassword.isEmpty)
                }
                .padding(.horizontal, 5)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 5)
            .padding(.top, 20)
        }
    }
}
