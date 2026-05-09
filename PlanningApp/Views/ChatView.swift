import SwiftUI

struct ChatView: View {
    @Environment(AppData.self) private var appData
    
    let collaborator1: Collaborator?
    let collaborator2: Collaborator?
    let team: Team?
    
    @State private var messageText: String = ""
    @State private var selectedSpeakerId: UUID?
    
    init(collaborator1: Collaborator, collaborator2: Collaborator) {
        self.collaborator1 = collaborator1
        self.collaborator2 = collaborator2
        self.team = nil
    }
    
    init(team: Team) {
        self.team = team
        self.collaborator1 = nil
        self.collaborator2 = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Simulation Banner
            HStack {
                Image(systemName: "person.badge.clock.fill").foregroundColor(.orange)
                Text("Parler en tant que :").font(.caption).fontWeight(.bold).foregroundColor(.orange)
                Picker("", selection: $selectedSpeakerId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(getAvailableSpeakers()) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(getMessages()) { message in
                            let isFromUser1 = message.senderId == (collaborator1?.id ?? UUID())
                            let sender = appData.collaborators.first(where: { $0.id == message.senderId })
                            
                            HStack(alignment: .bottom, spacing: 8) {
                                if isFromUser1 { Spacer() } else {
                                    Circle().fill(Color.gray.opacity(0.2)).frame(width: 32, height: 32)
                                        .overlay(Text(sender?.fullName.prefix(1) ?? "?").font(.caption).fontWeight(.bold))
                                }
                                
                                VStack(alignment: isFromUser1 ? .trailing : .leading, spacing: 4) {
                                    if team != nil && !isFromUser1 {
                                        Text(sender?.fullName ?? "Inconnu")
                                            .font(.caption2).foregroundColor(.secondary)
                                    }
                                    Text(message.content)
                                        .padding(.horizontal, 16).padding(.vertical, 10)
                                        .background(isFromUser1 ?
                                            AnyShapeStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                            AnyShapeStyle(Color(.secondarySystemGroupedBackground))
                                        )
                                        .foregroundColor(isFromUser1 ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    Text(formatTime(message.timestamp)).font(.caption2).foregroundColor(.secondary).padding(.horizontal, 4)
                                }
                                .frame(maxWidth: 260, alignment: isFromUser1 ? .trailing : .leading)
                                
                                if !isFromUser1 { Spacer() }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: getMessages().count) { _, _ in
                    if let lastMessage = getMessages().last {
                        withAnimation { proxy.scrollTo(lastMessage.id, anchor: .bottom) }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            
            // Input Bar
            VStack {
                Divider()
                HStack(spacing: 12) {
                    TextField("Votre message...", text: $messageText)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.03), radius: 3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundColor(canSendMessage() ? .white : .secondary)
                            .padding(10)
                            .background(canSendMessage() ? Color.blue : Color.clear)
                            .clipShape(Circle())
                    }
                    .disabled(!canSendMessage())
                }
                .padding(.horizontal).padding(.vertical, 10)
            }
            .background(.ultraThinMaterial)
        }
        .navigationTitle(team?.name ?? collaborator2?.fullName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let firstSpeaker = getAvailableSpeakers().first {
                selectedSpeakerId = firstSpeaker.id
            }
        }
    }
    
    func getMessages() -> [Message] {
        if let team = team {
            return appData.messages.filter { $0.teamId == team.id }.sorted { $0.timestamp < $1.timestamp }
        } else if let c1 = collaborator1, let c2 = collaborator2 {
            return appData.messages.filter {
                ($0.senderId == c1.id && $0.receiverId == c2.id) || ($0.senderId == c2.id && $0.receiverId == c1.id)
            }.sorted { $0.timestamp < $1.timestamp }
        }
        return []
    }
    
    func getAvailableSpeakers() -> [Collaborator] {
        if team != nil { return appData.collaborators }
        if let c1 = collaborator1, let c2 = collaborator2 { return [c1, c2] }
        return []
    }
    
    func canSendMessage() -> Bool {
        selectedSpeakerId != nil && !messageText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func sendMessage() {
        guard let senderId = selectedSpeakerId else { return }
        let newMessage: Message
        if let team = team {
            newMessage = Message(senderId: senderId, teamId: team.id, content: messageText, timestamp: Date())
        } else if let c2 = collaborator2 {
            newMessage = Message(senderId: senderId, receiverId: c2.id, content: messageText, timestamp: Date())
        } else { return }
        appData.addMessage(newMessage)
        messageText = ""
    }
    
    func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ChatView(collaborator1: Collaborator.mockCollaborators(teams: Team.mockTeams)[0],
                 collaborator2: Collaborator.mockCollaborators(teams: Team.mockTeams)[1])
    }
    .environment(AppData())
}
