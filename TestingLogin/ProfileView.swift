//
//  ProfileView.swift
//  TestingLogin
//
//  Created by Meriem Abid on 5/11/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditProfileView: Bool = false
    @State private var showChangePasswordView: Bool = false
    @State private var navigateToLogin = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var currentUserName: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color that adapts to light and dark mode
                (colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        
                        
                        Spacer().frame(height: 110)
                        
                       
                        
                        Spacer().frame(height: 60)
                        
                        // Buttons for Edit Profile, Change Password, and Logout
                        Button(action: {
                            showEditProfileView = true
                        }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(width: 320)
                                .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        Button(action: {
                            showChangePasswordView = true
                        }) {
                            Text("Change Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(width: 320)
                                .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        HStack {
                            Image(systemName: "newspaper")
                            .foregroundColor(.gray)
                            Text("Terms & Conditions")
                                .foregroundColor(Color.gray)
                            Spacer()
                            Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                            }
                        .frame(width: 290)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                                .onTapGesture {
                                                    if let url = URL(string: "https://www.freeprivacypolicy.com/live/e9a63b42-a84d-4785-8499-aeab786caff9") {
                                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                    }
                                                }

                        
                        HStack {
                            Image(systemName: "newspaper.circle")
                            .foregroundColor(.gray)
                            Text("Privacy Policy")
                                .foregroundColor(Color.gray)
                            Spacer()
                            Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                            }
                        .frame(width: 290)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                                .onTapGesture {
                                                    if let url = URL(string: "https://www.freeprivacypolicy.com/live/8bc8380f-53ec-4d70-bce5-822379a64c86") {
                                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                    }
                                                }
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.gray)
                                Text("Settings")
                                    .foregroundColor(Color.gray)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 290)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)}
                        
                        
                        HStack {
                            Image(systemName: "exclamationmark.bubble")
                            .foregroundColor(.gray)
                            Text("Help & Support")
                                .foregroundColor(Color.gray)
                            Spacer()
                            Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                            }
                        .frame(width: 290)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                        
                        
                        
                        Button(action: {
                            showAlert = true // Affiche l'alerte
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(width: 320)
                                .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Confirmation"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .destructive(Text("Logout")) {
                                    // Action de déconnexion
                                    TokenManager.shared.clearTokens()
                                    navigateToLogin = true
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        .fullScreenCover(isPresented: $navigateToLogin) {
                            LoginScreen(onLoginSuccess: {
                                self.navigateToLogin = false
                            })
                        }
                        
                    }
                    
                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading) {
                                            Button(action: {
                                                presentationMode.wrappedValue.dismiss()
                                            }) {
                                                HStack {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))// Change la couleur ici
                                                    Text("Back")
                                                        .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255)) // Change la couleur ici
                                                    
                                                    Spacer().frame(width: 90)
                                                    Text("My Profile")
                                                        .font(.headline)
                                                        
                                                        .foregroundColor(.primary)
                                                }
                                                
                                            }
                                        }
                                    }
                                .navigationBarBackButtonHidden(true)
                    .padding(.bottom, 20)
                    .sheet(isPresented: $showEditProfileView) {
                        EditProfile()
                            .presentationDetents([.height(350)])
                            .presentationCornerRadius(30)
                    }
                    .sheet(isPresented: $showChangePasswordView) {
                        ChangePassword()
                            .presentationDetents([.height(400)])
                            .presentationCornerRadius(30)
                    }
                    
                    Spacer().frame(height: 60)
                    

                }
                
            }
        }
    }
}
// Supporting Views for the Profile Screen
struct DocumentButton: View {
    let title: String
    let iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.green)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 350)
    }
}

struct OptionRow: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            Text(title)
                .foregroundColor(.primary)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.secondary)
        .cornerRadius(8)
        .shadow(radius: 1)
        .frame(maxWidth: .infinity)
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.light)
        
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
