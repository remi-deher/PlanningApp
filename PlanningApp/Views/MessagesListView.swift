import SwiftUI

struct MessagesListView: View {
    @Environment(AppData.self) private var appData
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Rechercher une conversation...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    let conversations = getFilteredConversations()
                    if conversations.isEmpty {
                        if searchText.isEmpty {
                            ContentUnavailableView("Aucune conversation", systemImage: "message.fill", description: Text("Les messages apparaîtront ici."))
                                .padding(.top, 40)
                        } else {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                        }
                    } else {
                        ForEach(conversations, id: \.id) { conv in
                            NavigationLink(destination: destinationView(for: conv)) {
                                ConversationRow(conv: conv)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
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
    
    struct Conversation: Identifiable {
        let id: String
        let title: String
        let icon: String
        let lastMessage: Message?
        let isTeam: Bool
        let user1: Collaborator?
        let user2: Collaborator?
        let team: Team?
        let color: Color
    }
    
    func getFilteredConversations() -> [Conversation] {
        let all = getConversations()
        if searchText.isEmpty { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    func getConversations() -> [Conversation] {
        var conversations: [String: Conversation] = [:]
        for message in appData.messages {
            if let teamId = message.teamId, let team = appData.teams.first(where: { $0.id == teamId }) {
                let key = teamId.uuidString
                if let existing = conversations[key], let existingMsg = existing.lastMessage, message.timestamp <= existingMsg.timestamp { continue }
                conversations[key] = Conversation(id: key, title: team.name, icon: "person.3.fill", lastMessage: message, isTeam: true, user1: nil, user2: nil, team: team, color: .blue)
            } else if let receiverId = message.receiverId,
                      let user1 = appData.collaborators.first(where: { $0.id == message.senderId }),
                      let user2 = appData.collaborators.first(where: { $0.id == receiverId }) {
                let ids = [user1.id.uuidString, user2.id.uuidString].sorted()
                let key = ids.joined(separator: "-")
                if let existing = conversations[key], let existingMsg = existing.lastMessage, message.timestamp <= existingMsg.timestamp { continue }
                conversations[key] = Conversation(id: key, title: "\(user1.fullName) & \(user2.fullName)", icon: "person.fill", lastMessage: message, isTeam: false, user1: user1, user2: user2, team: nil, color: .orange)
            }
        }
        return Array(conversations.values).sorted { ($0.lastMessage?.timestamp ?? Date()) > ($1.lastMessage?.timestamp ?? Date()) }
    }
}

struct ConversationRow: View {
    let conv: MessagesListView.Conversation
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(conv.color.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: conv.icon).foregroundColor(conv.color).font(.title3))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conv.title).fontWeight(.semibold).foregroundColor(.primary)
                    if conv.isTeam {
                        Text("Équipe").font(.caption2).fontWeight(.bold)
                            .foregroundColor(.blue).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1)).clipShape(Capsule())
                    }
                    Spacer()
                    if let lastMessage = conv.lastMessage {
                        Text(formatDate(lastMessage.timestamp)).font(.caption2).foregroundColor(.secondary)
                    }
                }
                if let lastMessage = conv.lastMessage {
                    Text(lastMessage.content).font(.caption).foregroundColor(.secondary).lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(date) ? "HH:mm" : "dd/MM"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack { MessagesListView() }
        .environment(AppData())
}
