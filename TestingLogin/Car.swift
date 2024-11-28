import Foundation
import UIKit

struct Car: Codable, Identifiable, Hashable {
    let id: String
    let make: String
    let carModel: String
    let year: Int
    let mileage: Int
    let owner: String?
    let imageUrl: String?
    let engine: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case make
        case carModel
        case year
        case mileage
        case owner
        case imageUrl
        case engine 

    }
}
