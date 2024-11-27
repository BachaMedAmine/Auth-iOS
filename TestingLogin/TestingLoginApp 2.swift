//
//  TestingLoginApp.swift
//  TestingLogin
//
//  Created by Meriem Abid on 13/10/2024.
//

import SwiftUI

@main
struct TestingLoginApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    WelcomeView(onContinue: {
                        // Perform an action or navigate
                        print("Continuing to the app!")
                    })
                } else {
                    LoginScreen(onLoginSuccess: {
                        self.isLoggedIn = true
                    })
                }
            }
            .onAppear {
                checkLoginStatus()
            }
        }
    }
    
    private func checkLoginStatus() {
        if TokenManager.shared.getToken(for: TokenManager.accessTokenKey) != nil,
           TokenManager.shared.getToken(for: TokenManager.refreshTokenKey) != nil {
            
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
