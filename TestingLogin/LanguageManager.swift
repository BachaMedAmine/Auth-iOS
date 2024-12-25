//
//  LanguageManager.swift
//  TestingLogin
//
//  Created by Meriem Abid on 11/12/2024.
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()

    /// Définir la langue
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()

        // Configurer la langue dans l'application
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") {
            Bundle.setLanguage(languageCode)
        }
    }

    /// Obtenir la langue actuelle
    func getLanguage() -> String {
        return UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.preferredLanguages.first ?? "en"
    }
}
