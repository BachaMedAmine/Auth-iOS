import SwiftUI

struct PasswordResetView: View {
    var email: String
    @Binding var otpText: String
    @Binding var showResetView: Bool

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var error: String?

    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("OTP", text: $otpText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 20)

            Button(action: resetPassword) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Submit")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || otpText.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword)
            .opacity(isLoading || otpText.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword ? 0.5 : 1.0)

            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
            if let message = message {
                Text(message)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.top, 10)
            }
        }
        .padding()
    }

    private func resetPassword() {
            guard newPassword == confirmPassword else {
                error = "Passwords do not match"
                return
            }

            print("Resetting password for \(email) with OTP \(otpText)") // Debugging
            
            NetworkService.shared.resetPassword(newPassword: newPassword, confirmPassword: confirmPassword) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("Password reset successful: \(message)") // Debugging
                    case .failure(let err):
                        self.error = err.localizedDescription
                        print("Error: \(err.localizedDescription)") // Debugging
                    }
                }
            }
        }
}
