//
//  NetworkService.swift
//  TestingLogin
//
//  Created by Meriem Abid on 8/11/2024.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseUrl = "http://localhost:3000/auth"
    private init() {}

    // Sign-Up method
    func signup(fullName: String, email: String, password: String, confirmPassword: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/signup") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": fullName,
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                // Check if access token is included
                if let accessToken = responseDict?["access_token"] as? String {
                    TokenManager.shared.saveToken(accessToken, for: TokenManager.accessTokenKey)
                    completion(.success("Signup successful and token saved"))
                } else {
                    let message = responseDict?["message"] as? String ?? "Signup successful"
                    completion(.success(message))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    
    
    
    
    

    // Sign-In and Save Tokens
    func signin(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/auth/login") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)

                
                // Save tokens
                TokenManager.shared.saveToken(decodedResponse.accessToken, for: TokenManager.accessTokenKey)
                TokenManager.shared.saveToken(decodedResponse.refreshToken, for: TokenManager.refreshTokenKey)

                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Create an Authenticated Request
    private func authenticatedRequest(for endpoint: String) -> URLRequest? {
        guard let url = URL(string: "\(baseUrl)/\(endpoint)") else { return nil }
        guard let accessToken = TokenManager.shared.getToken(for: TokenManager.accessTokenKey) else {
            print("No access token found. Please login.")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    // Refresh Access Token
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = TokenManager.shared.getToken(for: TokenManager.refreshTokenKey),
              let url = URL(string: "\(baseUrl)/refresh") else {
            TokenManager.shared.clearTokens() // Clear tokens if refresh fails
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Token refresh failed:", error)
                TokenManager.shared.clearTokens()
                completion(false)
                return
            }

            guard let data = data else {
                TokenManager.shared.clearTokens()
                completion(false)
                return
            }

            if let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let newAccessToken = responseDict["access_token"] {
                TokenManager.shared.saveToken(newAccessToken, for: TokenManager.accessTokenKey)
                completion(true)
            } else {
                TokenManager.shared.clearTokens()
                completion(false)
            }
        }.resume()
    }

    // Perform an Authenticated Request with Auto-Retry
    func performAuthenticatedRequest(endpoint: String, method: String = "GET", body: [String: Any]? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        guard var request = authenticatedRequest(for: endpoint) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
            return
        }
        
        request.httpMethod = method
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(data))
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                self.refreshAccessToken { success in
                    if success {
                        guard let retryRequest = self.authenticatedRequest(for: endpoint) else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
                            return
                        }
                        URLSession.shared.dataTask(with: retryRequest) { retryData, retryResponse, retryError in
                            if let retryData = retryData, let retryHttpResponse = retryResponse as? HTTPURLResponse, retryHttpResponse.statusCode == 200 {
                                completion(.success(retryData))
                            } else {
                                completion(.failure(retryError ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retry request"])))
                            }
                        }.resume()
                    } else {
                        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired, please log in again."])))
                    }
                }
            } else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        }.resume()
    }
    
    
    
    // Forgot Password Request
    func forgotPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
          guard let url = URL(string: "\(baseUrl)/forgot-password") else {
              completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
              return
          }

          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")

          let body: [String: String] = ["email": email]
          request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

          URLSession.shared.dataTask(with: request) { data, response, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }

              guard let data = data else {
                  completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                  return
              }

              do {
                  if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                     let message = responseDict["message"] as? String {
                      completion(.success(message))
                  } else {
                      completion(.failure(NSError(domain: "Unexpected server response", code: 500, userInfo: nil)))
                  }
              } catch {
                  completion(.failure(error))
              }
          }.resume()
      }
        
    // Verify OTP function
    func verifyOTP(otp: String, completion: @escaping (Result<String, Error>) -> Void) {
            guard let url = URL(string: "\(baseUrl)/verify-otp") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: String] = ["otp": otp]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                    return
                }

                do {
                    if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let accessToken = responseDict["accessToken"] as? String {
                        TokenManager.shared.saveToken(accessToken, for: TokenManager.accessTokenKey)
                        completion(.success("OTP verified successfully"))
                    } else {
                        completion(.failure(NSError(domain: "Unexpected server response", code: 500, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }

        // Reset Password
    func resetPassword(newPassword: String, confirmPassword: String, completion: @escaping (Result<String, Error>) -> Void) {
            guard let url = URL(string: "\(baseUrl)/reset-password") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(TokenManager.shared.getToken(for: TokenManager.accessTokenKey) ?? "")", forHTTPHeaderField: "Authorization")

            let body: [String: String] = [
                "newPassword": newPassword,
                "confirmPassword": confirmPassword
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                    return
                }

                do {
                    if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let accessToken = responseDict["accessToken"] as? String {
                        TokenManager.shared.saveToken(accessToken, for: TokenManager.accessTokenKey)
                        completion(.success("Password reset successfully"))
                    } else {
                        completion(.failure(NSError(domain: "Unexpected server response", code: 500, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }

    
    func fetchUserCars(completion: @escaping (Result<[Car], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/cars/owner") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Use POST as per your backend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TokenManager.shared.getToken(for: TokenManager.accessTokenKey) ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                return
            }

            // Log raw data for debugging
            print("Raw Data:", String(data: data, encoding: .utf8) ?? "Invalid Data")

            do {
                let cars = try JSONDecoder().decode([Car].self, from: data)
                completion(.success(cars))
            } catch {
                print("Decoding Error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func signupWithGoogle(idToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/auth/google-signup") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["idToken": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                // Decode the response
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = responseDict["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 400, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Google Login
       func googleLogin(idToken: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
           guard let url = URL(string: "\(baseUrl)/google/token") else { return }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           let body = ["idToken": idToken]
           request.httpBody = try? JSONSerialization.data(withJSONObject: body)
           
           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let data = data else {
                   completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                   return
               }
               
               do {
                   let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                   completion(.success(decodedResponse))
               } catch {
                   completion(.failure(error))
               }
           }.resume()
       }
    
    
    
    func updateUserName(newName: String, completion: @escaping (Result<String, Error>) -> Void) {
           guard let url = URL(string: "http://localhost:3000/auth/profile") else {
               completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
               return
           }

           guard let token = TokenManager.shared.getToken(for: TokenManager.accessTokenKey) else {
               completion(.failure(NSError(domain: "Missing Token", code: 401, userInfo: nil)))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "PUT"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

           let body: [String: String] = ["name": newName]
           request.httpBody = try? JSONSerialization.data(withJSONObject: body)

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                   completion(.failure(NSError(domain: "Invalid Response", code: 500, userInfo: nil)))
                   return
               }

               guard let data = data else {
                   completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                   return
               }

               do {
                   let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                   if let message = responseJSON?["message"] as? String {
                       completion(.success(message))
                   } else {
                       completion(.failure(NSError(domain: "Invalid JSON Structure", code: 500, userInfo: nil)))
                   }
               } catch {
                   completion(.failure(error))
               }
           }.resume()
       }
    
    
}