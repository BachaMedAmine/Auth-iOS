//
//  SignupScreen.swift
//  TestingLogin
//
//  Created by Meriem Abid on 15/10/2024.
//

import SwiftUI
import GoogleSignIn

struct SignupScreen: View {
    @State private var fullName: String = ""
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullNameError: String? = nil
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmPasswordError: String? = nil
    @State private var isChecked: Bool = false
    
    @State private var showLogin = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                // Logo
                Image("car")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                
                Spacer().frame(height: 10)
                
                Text("Welcome 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 14)
                
                HStack(spacing: 0) {
                    Text("to ")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Text("OVA")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                }
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .center) {
                    Text("Sign up to get started using email or social networks")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    Text("networks")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 24)
                    
                    VStack(spacing: 27) {
                        CustomTF(sfIcon: "person", hint: "Full Name", value: $fullName)
                        
                        CustomTF(sfIcon: "at", hint: "Email Address", value: $emailAddress)
                        
                        CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $password)
                        
                        CustomTF(sfIcon: "lock.shield", hint: "Confirm Password", isPassword: true, value: $confirmPassword)
                    }
                    
                    // Checkbox
                    HStack {
                        Button(action: {
                            
                            isChecked.toggle()
                        }) {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                .foregroundColor(isChecked ? Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255) : Color.gray)
                                .font(.system(size: 24))
                        }
                        
                        Text("I accept ")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.primary)
                                                
                                                Link("terms and conditions", destination: URL(string: "https://www.freeprivacypolicy.com/live/e9a63b42-a84d-4785-8499-aeab786caff9")!) // Lien vers les termes et conditions
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                            
                    }
                    .padding()
                    
                    Button(action: {
                                if validateForm() {
                                    NetworkService.shared.signup(fullName: fullName, email: emailAddress, password: password, confirmPassword: confirmPassword) { result in
                                        switch result {
                                        case .success(let message):
                                            print("Signup successful: \(message)")
                                            navigateToLogin = true // Trigger navigation
                                        case .failure(let error):
                                            print("Signup failed: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Signup")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disableWithOpacity(fullName.isEmpty || emailAddress.isEmpty || password.isEmpty || confirmPassword.isEmpty || !isChecked)

                            // NavigationLink for navigation to LoginScreen
                            NavigationLink(
                                destination: LoginScreen(onLoginSuccess: {
                                    print("User logged in successfully")
                                }), // Pass the appropriate closure or functionality here
                                isActive: $navigateToLogin
                            ) {
                                EmptyView()
                            }
                        
                    Spacer().frame(height: 30)
                    // Social login buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            
                            googleSignup()
                            
                        }) {
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
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("Already have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showLogin.toggle()
                        }) {
                            Text("Login")
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                        }
                    }
                    .navigationDestination(isPresented: $showLogin) {
                        LoginScreen(onLoginSuccess: {
                            self.showLogin = false // Adjust as needed for navigation behavior
                        })
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    
    
    
    
    private func googleSignup() {
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
                print("Google Signup Error: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Unable to retrieve Google ID token.")
                return
            }

            print("Google ID Token: \(idToken)")

            NetworkService.shared.signupWithGoogle(idToken: idToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("Signup successful: \(message)")
                        navigateToLogin = true
                    case .failure(let error):
                        print("Signup failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    
    
    func validateForm() -> Bool {
        // Reset errors
        fullNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        
        // Validate full name
        if fullName.isEmpty {
            alertMessage = "Full name is required."
            showAlert = true
            return false
        }
        
        // Validate email
        if emailAddress.isEmpty || !isValidEmail(emailAddress) {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return false
        }
        
        // Validate password
        if password.isEmpty || password.count < 6 {
            alertMessage = "Password must be at least 6 characters."
            showAlert = true
            return false
        }
        
        // Validate confirm password
        if confirmPassword != password {
            alertMessage = "Passwords do not match."
            showAlert = true
            return false
        }
        
        // Validate checkbox
        if !isChecked {
            alertMessage = "You must accept the terms and conditions."
            showAlert = true
            return false
        }
        
        // If all validations pass
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Simple email regex for validation
        let regex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regex)
        return pred.evaluate(with: email)
    }
    
    
}

