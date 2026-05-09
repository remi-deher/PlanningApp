import Foundation

struct Schedule: Identifiable, Codable {
    var id = UUID()
    var collaboratorId: UUID
    var startTime: Date
    var endTime: Date
    var notes: String?
}

// Mock Data
extension Schedule {
    static func mockSchedules(collaborators: [Collaborator]) -> [Schedule] {
        guard collaborators.count >= 4 else { return [] }
        let now = Date()
        let calendar = Calendar.current
        
        // Helper to create dates
        func createDate(days: Int, hour: Int) -> Date {
            let date = calendar.date(byAdding: .day, value: days, to: now)!
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
        }
        
        return [
            Schedule(collaboratorId: collaborators[0].id, startTime: createDate(days: 0, hour: 8), endTime: createDate(days: 0, hour: 16), notes: "Shift du matin"),
            Schedule(collaboratorId: collaborators[1].id, startTime: createDate(days: 0, hour: 8), endTime: createDate(days: 0, hour: 16)),
            Schedule(collaboratorId: collaborators[2].id, startTime: createDate(days: 0, hour: 20), endTime: createDate(days: 1, hour: 4), notes: "Nuit"),
            Schedule(collaboratorId: collaborators[3].id, startTime: createDate(days: 1, hour: 9), endTime: createDate(days: 1, hour: 17))
        ]
    }
}
