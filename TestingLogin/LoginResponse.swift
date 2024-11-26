//
//  LoginResponse.swift
//  TestingLogin
//
//  Created by Meriem Abid on 7/11/2024.
//

import Foundation
import SwiftUI


struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponse

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct UserResponse: Decodable {
    let email: String
    let name: String
    let cars: [Car]
}




