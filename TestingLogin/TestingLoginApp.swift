//
//  TestingLoginApp.swift
//  TestingLogin
//
//  Created by Meriem Abid on 13/10/2024.
//

import SwiftUI



@main
struct TestingLoginApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Track if the user is logged in
    @AppStorage("isFirstTimeUser") private var isFirstTimeUser: Bool = true // Track if it's the user's first time

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    // If logged in, navigate based on first-time status
                    if isFirstTimeUser {
                        WelcomeView(onContinue: {
                            print("Navigating to HomePage from WelcomeView")
                            logNavigation(from: "WelcomeView", to: "HomePage")

                            isFirstTimeUser = false // Set first-time status to false
                        })
                    } else {
                        HomePage() // Show HomePage if not a first-time user
                            .onAppear {
                                print("🟢 Currently on: HomePage")
                      }
                        
                    }
                } else {
                    // Show login screen for unauthenticated users
                    LoginScreen(onLoginSuccess: {
                        logNavigation(from: "LoginScreen", to: "WelcomeView or HomePage")

                        print("Login success: Navigating to Welcome or HomePage")

                        self.isLoggedIn = true // Set logged-in status
                    })
                }
            }
            .onAppear {
                checkFirstTimeUser()
                checkLoginStatus()
                print("App launched")
                print("isLoggedIn:", isLoggedIn)
                print("isFirstTimeUser:", isFirstTimeUser)
                print("🟢 App launched")
                print("isLoggedIn:", isLoggedIn)
                print("isFirstTimeUser:", isFirstTimeUser)
            }
        }
    }
    
    private func checkFirstTimeUser() {
        // Check if the cars array is empty
        if CarManager.shared.cars.isEmpty {
            isFirstTimeUser = true
        } else {
            isFirstTimeUser = false
        }
    }

    private func checkLoginStatus() {
        // Check if access and refresh tokens exist
        if TokenManager.shared.getToken(for: TokenManager.accessTokenKey) != nil,
           TokenManager.shared.getToken(for: TokenManager.refreshTokenKey) != nil {
            
            // Validate tokens by performing an authenticated request
            NetworkService.shared.performAuthenticatedRequest(endpoint: "ping") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.isLoggedIn = true
                    case .failure:
                        self.isLoggedIn = false
                    }
                }
            }
        } else {
            isLoggedIn = false
        }
    }
}
