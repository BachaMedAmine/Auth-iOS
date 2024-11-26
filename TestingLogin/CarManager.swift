//
//  CarManager.swift
//  TestingLogin
//
//  Created by Meriem Abid on 15/11/2024.
//

import Foundation

class CarManager: ObservableObject {
    static let shared = CarManager()
    @Published var cars: [Car] = [] {
        didSet {
            saveCarsToDefaults()
        }
    }

    private init() {
        loadCarsFromDefaults()
    }

    func saveCarsToDefaults() {
        let encoder = JSONEncoder()
        if let encodedCars = try? encoder.encode(cars) {
            UserDefaults.standard.set(encodedCars, forKey: "userCars")
        }
    }

    func loadCarsFromDefaults() {
        if let savedCars = UserDefaults.standard.data(forKey: "userCars"),
           let decodedCars = try? JSONDecoder().decode([Car].self, from: savedCars) {
            cars = decodedCars
        }
    }
}
