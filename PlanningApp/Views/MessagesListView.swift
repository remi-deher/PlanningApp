import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        List {
            let conversations = getConversations()
            
            ForEach(conversations, id: \.id) { conv in
                NavigationLink(destination: destinationView(for: conv)) {
                    HStack(spacing: 15) {
                        Image(systemName: conv.icon)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(5)
                            .background(conv.isTeam ? Color.accentColor.opacity(0.1) : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(conv.isTeam ? .accentColor : .secondary)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(conv.title)
                                .fontWeight(.semibold)
                            
                            if let lastMessage = conv.lastMessage {
                                Text(lastMessage.content)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        if let lastMessage = conv.lastMessage {
                            Text(formatDate(lastMessage.timestamp))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Messages")
    }
    
    @ViewBuilder
    func destinationView(for conv: Conversation) -> some View {
        if conv.isTeam, let team = conv.team {
            ChatView(team: team)
        } else if let u1 = conv.user1, let u2 = conv.user2 {
            ChatView(collaborator1: u1, collaborator2: u2)
        } else {
            Text("Erreur de conversation")
        }
    }
    
    // Helper to group messages into conversations
    struct Conversation: Identifiable {
        let id: String
        let title: String
        let icon: String
        let lastMessage: Message?
        let isTeam: Bool
        let user1: Collaborator?
        let user2: Collaborator?
        let team: Team?
    }
    
    func getConversations() -> [Conversation] {
        var conversations: [String: Conversation] = [:]
        
        for message in appData.messages {
            if let teamId = message.teamId, let team = appData.teams.first(where: { $0.id == teamId }) {
                // Team Conversation
                let key = teamId.uuidString
                if let existing = conversations[key] {
                    if let existingMsg = existing.lastMessage, message.timestamp > existingMsg.timestamp {
                        conversations[key] = Conversation(id: key, title: "[Équipe] \(team.name)", icon: "person.3.fill", lastMessage: message, isTeam: true, user1: nil, user2: nil, team: team)
                    }
                } else {
                    conversations[key] = Conversation(id: key, title: "[Équipe] \(team.name)", icon: "person.3.fill", lastMessage: message, isTeam: true, user1: nil, user2: nil, team: team)
                }
            } else if let receiverId = message.receiverId,
                      let user1 = appData.collaborators.first(where: { $0.id == message.senderId }),
                      let user2 = appData.collaborators.first(where: { $0.id == receiverId }) {
                // Private Conversation
                let ids = [user1.id.uuidString, user2.id.uuidString].sorted()
                let key = ids.joined(separator: "-")
                
                if let existing = conversations[key] {
                    if let existingMsg = existing.lastMessage, message.timestamp > existingMsg.timestamp {
                        conversations[key] = Conversation(id: key, title: "\(user1.fullName) & \(user2.fullName)", icon: "person.circle.fill", lastMessage: message, isTeam: false, user1: user1, user2: user2, team: nil)
                    }
                } else {
                    conversations[key] = Conversation(id: key, title: "\(user1.fullName) & \(user2.fullName)", icon: "person.circle.fill", lastMessage: message, isTeam: false, user1: user1, user2: user2, team: nil)
                }
            }
        }
        
        return Array(conversations.values).sorted { ($0.lastMessage?.timestamp ?? Date()) > ($1.lastMessage?.timestamp ?? Date()) }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct MessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessagesListView()
                .environmentObject(AppData())
        }
    }
}
