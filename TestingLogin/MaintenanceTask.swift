import Foundation

struct MaintenanceTask: Decodable, Identifiable {
    public let _id: String? // MongoDB `_id`
    var id: String {
        if let _id = _id, !_id.isEmpty {
            return _id
        } else {
            // Log warning for debugging and return a unique UUID
            print("Warning: Task ID is nil or empty. Assigning UUID.")
            return UUID().uuidString
        }
    } // Use `_id` or fallback to UUID
    let carId: String
    let task: String
    var dueDate: String? = nil
    var nextMileage: Int? = 0
    var status: String = "Pending" 
    
    var iconName: String {
        switch task {
        case "Oil Change": return "drop.fill"
        case "Tire Rotation": return "arrow.triangle.2.circlepath"
        case "Brake Change": return "car.fill"
        case "Tire Replacement": return "wrench.fill"
        case "Timing Chain Replacement": return "clock.fill"
        default: return "gearshape.fill"
        }
    }

    enum CodingKeys: String, CodingKey {
         case _id = "_id"
         case carId
         case task
         case dueDate
         case nextMileage
         case status
     }
    
    // Custom initializer for creating tasks manually
    init(_id: String? = nil, carId: String, task: String, dueDate: String?, nextMileage: Int?, status: String) {
        self._id = _id
        self.carId = carId
        self.task = task
        self.dueDate = dueDate
        self.nextMileage = nextMileage
        self.status = status
    }

    // Decoding initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        carId = try container.decode(String.self, forKey: .carId)
        task = try container.decode(String.self, forKey: .task)
        dueDate = try container.decodeIfPresent(String.self, forKey: .dueDate)
        nextMileage = try container.decodeIfPresent(Int.self, forKey: .nextMileage)
        status = try container.decode(String.self, forKey: .status)

        // Debug logs for decoding
        print("Decoded MaintenanceTask:")
        print("_id: \(_id ?? "nil")")
        print("carId: \(carId)")
        print("task: \(task)")
        print("dueDate: \(dueDate ?? "nil")")
        print("nextMileage: \(nextMileage ?? 0)")
        print("status: \(status)")
    }
    
    var formattedDueDate: String {
        guard let dueDate = self.dueDate else { return "N/A" }
        let isoFormatter = ISO8601DateFormatter()
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        if let date = isoFormatter.date(from: dueDate) {
            return displayFormatter.string(from: date)
        } else {
            print("Warning: Invalid date format for dueDate: \(dueDate)")
            return "Invalid Date"
        }
    }
}
