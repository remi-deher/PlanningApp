import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        List {
            let conversations = getConversations()
            
            ForEach(conversations, id: \.id) { conv in
                NavigationLink(destination: ChatView(collaborator1: conv.user1, collaborator2: conv.user2)) {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(conv.user1.fullName) & \(conv.user2.fullName)")
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
    
    // Helper to group messages into conversations
    struct Conversation: Identifiable {
        let id: String
        let user1: Collaborator
        let user2: Collaborator
        let lastMessage: Message?
    }
    
    func getConversations() -> [Conversation] {
        var conversations: [String: Conversation] = [:]
        
        for message in appData.messages {
            guard let user1 = appData.collaborators.first(where: { $0.id == message.senderId }),
                  let user2 = appData.collaborators.first(where: { $0.id == message.receiverId }) else {
                continue
            }
            
            // Create a unique key for the pair (sorted IDs to ensure order doesn't matter)
            let ids = [user1.id.uuidString, user2.id.uuidString].sorted()
            let key = ids.joined(separator: "-")
            
            if let existing = conversations[key] {
                if let existingMsg = existing.lastMessage, message.timestamp > existingMsg.timestamp {
                    conversations[key] = Conversation(id: key, user1: user1, user2: user2, lastMessage: message)
                }
            } else {
                conversations[key] = Conversation(id: key, user1: user1, user2: user2, lastMessage: message)
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
