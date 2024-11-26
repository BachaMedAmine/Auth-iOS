import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    // Make these keys static and public to access them across the app
    static let accessTokenKey = "access_token"
    static let refreshTokenKey = "refresh_token"
    
    private init() {} // Private initializer to enforce singleton
    
    // Save token to UserDefaults
    func saveToken(_ token: String, for key: String) {
        UserDefaults.standard.set(token, forKey: key)
    }
    
    // Retrieve token from UserDefaults
    func getToken(for key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    // Clear both access and refresh tokens
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: TokenManager.accessTokenKey)
        UserDefaults.standard.removeObject(forKey: TokenManager.refreshTokenKey)
    }
}
