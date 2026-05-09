import Foundation

struct Message: Identifiable, Codable {
    var id = UUID()
    var senderId: UUID
    var receiverId: UUID? // Optionnel si c'est un message d'équipe
    var teamId: UUID?     // Optionnel si c'est un message privé
    var content: String
    var timestamp: Date
}

// Mock Data
extension Message {
    static func mockMessages(collaborators: [Collaborator], teams: [Team]) -> [Message] {
        guard collaborators.count >= 4, teams.count >= 1 else { return [] }
        let now = Date()
        
        return [
            // Messages privés
            Message(senderId: collaborators[0].id, receiverId: collaborators[1].id, content: "Bonjour Marie, tu confirmes ton shift de demain ?", timestamp: now.addingTimeInterval(-3600)),
            Message(senderId: collaborators[1].id, receiverId: collaborators[0].id, content: "Oui Jean, c'est tout bon pour moi !", timestamp: now.addingTimeInterval(-1800)),
            Message(senderId: collaborators[2].id, receiverId: collaborators[3].id, content: "Salut Sophie, tu as fini le rapport ?", timestamp: now.addingTimeInterval(-7200)),
            Message(senderId: collaborators[3].id, receiverId: collaborators[2].id, content: "Bientôt, je te l'envoie avant de partir.", timestamp: now.addingTimeInterval(-5400)),
            
            // Messages d'équipe
            Message(senderId: collaborators[0].id, teamId: teams[0].id, content: "Message d'équipe : N'oubliez pas la réunion de demain matin !", timestamp: now.addingTimeInterval(-9000)),
            Message(senderId: collaborators[1].id, teamId: teams[0].id, content: "Bien reçu !", timestamp: now.addingTimeInterval(-8500))
        ]
    }
}
