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
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color that adapts to light and dark mode
                (colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        Text("My Profile")
                            .font(.headline)
                            .padding(.top)
                        
                        Spacer().frame(height: 90)
                        
                        Text("Profile View")
                            .font(.title2)
                            .bold()
                        
                        Spacer().frame(height: 60)
                        
                        // Buttons for Edit Profile, Change Password, and Logout
                        Button(action: {
                            showEditProfileView = true
                        }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(width: 300)
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
                                .frame(width: 300)
                                .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        Button(action: {
                            showAlert = true // Affiche l'alerte
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .frame(width: 300)
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
                    
                    Divider().padding(.vertical)
                    
                    // Options Section
                    /*VStack(spacing: 16) {
                     OptionRow(title: "My Profile", iconName: "person.fill")
                     OptionRow(title: "My Bookings", iconName: "calendar")
                     OptionRow(title: "Settings", iconName: "gearshape.fill")
                     }
                     .padding(.horizontal)*/
                    
                    
                    
                    // Bottom Navigation Bar
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
