struct MaintenanceTask: Decodable, Identifiable {
    let id: String
    let carId: String
    let task: String
    let dueDate: String? // Optional because it can be null
    let status: String
    let lastMileage: String // Always a string
    let nextMileage: String // Always a string

    var iconName: String {
        switch task {
        case "Oil Change": return "drop.fill"
        case "Tire Rotation": return "arrow.triangle.2.circlepath"
        case "Brake Change": return "car.fill"
        case "Tire Replacement": return "wrench.fill"
        default: return "gearshape.fill"
        }
    }
}
