import Foundation

struct Collaborator: Identifiable, Codable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var role: String
    var teamId: UUID?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// Mock Data
extension Collaborator {
    static func mockCollaborators(teams: [Team]) -> [Collaborator] {
        guard teams.count >= 3 else { return [] }
        return [
            Collaborator(firstName: "Jean", lastName: "Dupont", role: "Manager", teamId: teams[0].id),
            Collaborator(firstName: "Marie", lastName: "Curie", role: "Technicienne", teamId: teams[0].id),
            Collaborator(firstName: "Pierre", lastName: "Gaspard", role: "Opérateur", teamId: teams[1].id),
            Collaborator(firstName: "Sophie", lastName: "Martin", role: "Support", teamId: teams[2].id),
            Collaborator(firstName: "Lucas", lastName: "Dubois", role: "Opérateur", teamId: teams[1].id)
        ]
    }
}
