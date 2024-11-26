import SwiftUI

struct OTPVerificationView: View {
    @Binding var otpText: String
    @Binding var showResetView: Bool
    @State private var error: String?
    @FocusState private var isKeyboardShowing: Bool
    @State private var email: String = ""  // Make sure this email is set before calling verifyOTP
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        VStack {
            Text("Verify OTP")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { index in
                    OTPTextBox(index)
                }
            }
            .background {
                TextField("", text: $otpText.limit(6))
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(width: 1, height: 1)
                    .opacity(0.001)
                    .focused($isKeyboardShowing)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardShowing.toggle()
            }
            .onAppear {
                isKeyboardShowing = true
            }
            .padding(.bottom, 20)
            .padding(.top, 10)
            
            Button(action: verifyOTP) {
                Text("Verify")
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                    }
            }
            .disabled(otpText.count < 6)
            .padding()
            .sheet(isPresented: $showResetView, content: {
                PasswordResetView(email: email, otpText: $otpText, showResetView: $showResetView)
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(30)
            })
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func verifyOTP() {
        print("Email: \(email), OTP: \(otpText)") // Debugging

        guard otpText.count == 6 else {
            error = "Please enter a valid 6-digit OTP"
            return
        }

        // Call the verifyOTP endpoint
        NetworkService.shared.verifyOTP(otp: otpText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("OTP verified successfully: \(message)") // Debugging
                    showResetView = true
                    activeSheet = .passwordReset
                case .failure(let err):
                    self.error = err.localizedDescription
                    print("Error: \(err.localizedDescription)") // Debugging
                }
            }
        }
    }
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let charIndex = otpText.index(otpText.startIndex, offsetBy: index)
                Text(String(otpText[charIndex]))
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.gray, lineWidth: 0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue },
            set: {
                if $0.count <= length {
                    self.wrappedValue = $0
                }
            }
        )
    }
}
