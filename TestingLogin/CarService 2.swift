//
//  CarService.swift
//  TestingLogin
//
//  Created by Meriem Abid on 19/11/2024.
//

import Foundation

class CarService {
    static let shared = CarService()
    
    private init() {}
    
    func fetchUserCars(completion: @escaping (Result<[Car], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Adjust if your API requires POST
        request.setValue("Bearer \(TokenManager.shared.getToken(for: TokenManager.accessTokenKey) ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let cars = try JSONDecoder().decode([Car].self, from: data)
                completion(.success(cars))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
