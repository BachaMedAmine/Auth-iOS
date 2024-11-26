//
//  ContentView.swift
//  TestingLogin
//
//  Created by Meriem Abid on 13/10/2024.
//

import SwiftUI
import GoogleSignIn

enum ActiveSheet: Identifiable {
    case forgotPassword
    case passwordReset
    case otpVerification
    
    var id: Self { self }
}



struct LoginScreen: View {
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var showSignup = false
    @State private var showForgotPasswordView: Bool = false
    @State private var showResetView: Bool = false
    @State private var showError = false
    @State private var isVerified: Bool = false
    @State private var askOTP: Bool = false
    @State private var otpText: String = ""
    @State private var activeSheet: ActiveSheet?
    @State private var shouldNavigateToHome = false // For HomePage
    @State private var shouldNavigateToWelcome = false // For WelcomeView
    @State private var errorMessage = ""
    @State private var email: String = ""
    
    var onLoginSuccess: () -> Void

    func logNavigation(from currentPage: String, to targetPage: String) {
        print("🔵 Navigation: From '\(currentPage)' to '\(targetPage)'")
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack
                {
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .center) {
                        Image("car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                        
                        Spacer().frame(height: 10)
                        
                        Text("Welcome Back 👋")
                            .font(.system(size: min(geometry.size.width * 0.08, 28), weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.bottom, 14)
                        
                        HStack(spacing: 0) {
                            Text("to ")
                                .font(.system(size: min(geometry.size.width * 0.08, 28), weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("OVA")
                                .font(.system(size: min(geometry.size.width * 0.08, 28), weight: .bold))
                                .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                        }
                        
                        Spacer().frame(height: 20)
                        
                        VStack(alignment: .center) {
                            Text("Log in to your account using email or social")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                            
                            Text("networks")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 24)
                            
                                
                            
                            VStack(spacing: 27) {
                                CustomTF(sfIcon: "at", hint: "Email Address", value: $emailAddress)
                                CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $password)
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        activeSheet = .forgotPassword
                                        showForgotPasswordView.toggle()
                                    }) {
                                        Text("Forgot Password?")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                    
                                }
                                
                                Button(action: login) {
                                    Text("Login")
                                        .foregroundColor(.primary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                        .cornerRadius(10)
                                }
                              
                                .padding(.horizontal)
                                .disableWithOpacity(emailAddress.isEmpty || password.isEmpty)
                                .alert(isPresented: $showError) {
                                            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                                        }
                                
                                Spacer()
                                
                                HStack {
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                    
                                    Text("Or continue with social account")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                    
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                }
                                .padding(.vertical)
                                
                                HStack(spacing: 16) {
                                    Button(action: googleSignIn) {
                                        HStack {
                                            Image("google_icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text("Google")
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    Button(action: {
                                        // Handle Apple login
                                    }) {
                                        HStack {
                                            Image("apple_icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text("Apple")
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text("Didn't have an account? ")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        showSignup.toggle()
                                    }) {
                                        Text("Signup")
                                            .font(.system(size: 14))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                }
                                .padding(.top, 20)
                                .navigationDestination(isPresented: $showSignup) {
                                    SignupScreen()
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                }
                .navigationDestination(isPresented: $shouldNavigateToHome) {
                    
                    HomePage()
                }
                .navigationDestination(isPresented: $shouldNavigateToWelcome) {
                    WelcomeView(onContinue: {
                        shouldNavigateToWelcome = false
                        shouldNavigateToHome = true // Transition to HomePage after WelcomeView
                    })
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showForgotPasswordView) {
                ForgotPassword(showResetView: $showResetView, activeSheet: $activeSheet)
                    .presentationDetents([.height(300)])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showResetView) {
                PasswordResetView(email: email, otpText: $otpText,showResetView: $showResetView)
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(30)
            }
            .sheet(isPresented: $askOTP) {
                OTPVerificationView(otpText: $otpText, showResetView: $showResetView, activeSheet: $activeSheet)
                    .onDisappear {
                                // Reset state when OTPVerificationView is dismissed
                                showForgotPasswordView = false
                                askOTP = false
                                showResetView = false
                            }
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(20)
            }
        }
    }
    
    private func login() {
        NetworkService.shared.signin(email: emailAddress, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let decodedResponse):
                    print("Decoded Response: \(decodedResponse)")

                    // Update CarManager with cars from the response
                    CarManager.shared.cars = decodedResponse.user.cars

                    // Check if there are any cars
                    if decodedResponse.user.cars.isEmpty {
                        logNavigation(from: "LoginScreen", to: "WelcomeView")

                        shouldNavigateToWelcome = true // Navigate to WelcomeView
                    } else {
                        logNavigation(from: "LoginScreen", to: "HomePage")

                        shouldNavigateToHome = true // Navigate to HomePage
                    }
                case .failure(let error):
                    errorMessage = "Login failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    private func googleSignIn() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            print("Google Client ID not found.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let presentingVC = getRootViewController() else {
            print("Unable to find root view controller.")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Google Login Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Unable to retrieve Google ID token.")
                return
            }
            
            // Perform Google Login
            NetworkService.shared.googleLogin(idToken: idToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let decodedResponse):
                        print("Google Login Success: \(decodedResponse)")
                        
                        // Save tokens
                        TokenManager.shared.saveToken(decodedResponse.accessToken, for: TokenManager.accessTokenKey)
                        TokenManager.shared.saveToken(decodedResponse.refreshToken, for: TokenManager.refreshTokenKey)
                        
                        // Check navigation conditions
                        if decodedResponse.user.cars.isEmpty {
                            shouldNavigateToWelcome = true
                        } else {
                            shouldNavigateToHome = true
                        }
                    case .failure(let error):
                        print("Google Login Failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    private func getRootViewController() -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    private func sendTokenToBackend(idToken: String) {
        guard let url = URL(string: "http://localhost:3000/auth/google/token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["idToken": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to backend: \(error)")
                return
            }
            
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("Backend response: \(response)")
            }
        }.resume()
    }
}
