import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appData: AppData
    
    // Pour le mode privé
    let collaborator1: Collaborator?
    let collaborator2: Collaborator?
    
    // Pour le mode équipe
    let team: Team?
    
    @State private var messageText: String = ""
    @State private var selectedSpeakerId: UUID?
    
    // Initialiseur pour chat privé
    init(collaborator1: Collaborator, collaborator2: Collaborator) {
        self.collaborator1 = collaborator1
        self.collaborator2 = collaborator2
        self.team = nil
    }
    
    // Initialiseur pour chat d'équipe
    init(team: Team) {
        self.team = team
        self.collaborator1 = nil
        self.collaborator2 = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Simulation Banner
            HStack {
                Image(systemName: " person.badge.clock.fill")
                    .foregroundColor(.orange)
                Text("Mode Simulation")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Picker("En tant que :", selection: $selectedSpeakerId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(getAvailableSpeakers()) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
                .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        let messages = getMessages()
                        
                        ForEach(messages) { message in
                            let isFromUser1 = message.senderId == (collaborator1?.id ?? UUID())
                            let sender = appData.collaborators.first(where: { $0.id == message.senderId })
                            
                            HStack(alignment: .bottom, spacing: 8) {
                                if isFromUser1 {
                                    Spacer()
                                } else {
                                    // Avatar for other sender
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text(sender?.fullName.prefix(1) ?? "?")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        )
                                }
                                
                                VStack(alignment: isFromUser1 ? .trailing : .leading, spacing: 4) {
                                    // Afficher le nom de l'expéditeur si c'est un message d'équipe
                                    if team != nil && !isFromUser1 {
                                        Text(sender?.fullName ?? "Inconnu")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(message.content)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(isFromUser1 ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom))
                                        .foregroundColor(isFromUser1 ? .white : .primary)
                                        .clipShape(RoundedCorner(radius: 18, corners: isFromUser1 ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    
                                    Text(formatTime(message.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                }
                                .frame(maxWidth: 260, alignment: isFromUser1 ? .trailing : .leading)
                                
                                if !isFromUser1 {
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: getMessages().count) { _ in
                    if let lastMessage = getMessages().last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            
            // Input Bar
            VStack {
                Divider()
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    TextField("Votre message...", text: $messageText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    
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
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color(.secondarySystemGroupedBackground))
        }
        .navigationTitle(team?.name ?? collaborator2?.fullName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Sélectionner par défaut le premier participant
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
                ($0.senderId == c1.id && $0.receiverId == c2.id) ||
                ($0.senderId == c2.id && $0.receiverId == c1.id)
            }.sorted { $0.timestamp < $1.timestamp }
        }
        return []
    }
    
    func getAvailableSpeakers() -> [Collaborator] {
        if team != nil {
            return appData.collaborators
        } else if let c1 = collaborator1, let c2 = collaborator2 {
            return [c1, c2]
        }
        return []
    }
    
    func canSendMessage() -> Bool {
        return selectedSpeakerId != nil && !messageText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func sendMessage() {
        guard let senderId = selectedSpeakerId else { return }
        
        let newMessage: Message
        if let team = team {
            newMessage = Message(senderId: senderId, teamId: team.id, content: messageText, timestamp: Date())
        } else if let c2 = collaborator2 {
            newMessage = Message(senderId: senderId, receiverId: c2.id, content: messageText, timestamp: Date())
        } else {
            return
        }
        
        appData.addMessage(newMessage)
        messageText = ""
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Helper to round specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(collaborator1: Collaborator.mockCollaborators(teams: Team.mockTeams)[0],
                     collaborator2: Collaborator.mockCollaborators(teams: Team.mockTeams)[1])
                .environmentObject(AppData())
        }
    }
}
