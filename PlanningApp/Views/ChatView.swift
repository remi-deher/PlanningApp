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
        VStack {
            ScrollView {
                VStack(spacing: 15) {
                    let messages = getMessages()
                    
                    ForEach(messages) { message in
                        let isFromUser1 = message.senderId == (collaborator1?.id ?? UUID())
                        let sender = appData.collaborators.first(where: { $0.id == message.senderId })
                        
                        HStack {
                            if isFromUser1 {
                                Spacer()
                            }
                            
                            VStack(alignment: isFromUser1 ? .trailing : .leading) {
                                // Afficher le nom de l'expéditeur si c'est un message d'équipe
                                if team != nil && !isFromUser1 {
                                    Text(sender?.fullName ?? "Inconnu")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 5)
                                }
                                
                                Text(message.content)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(isFromUser1 ? Color.accentColor : Color(UIColor.secondarySystemGroupedBackground))
                                    .foregroundColor(isFromUser1 ? .white : .primary)
                                    .cornerRadius(18)
                                
                                Text(formatTime(message.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 5)
                            }
                            
                            if !isFromUser1 {
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Barre de saisie (Simulation)
            VStack(spacing: 10) {
                HStack {
                    Text("Parler en tant que :")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Expéditeur", selection: $selectedSpeakerId) {
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
                
                HStack {
                    TextField("Votre message...", text: $messageText)
                        .padding(10)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(canSendMessage() ? .accentColor : .secondary)
                            .padding(10)
                            .background(canSendMessage() ? Color.accentColor.opacity(0.1) : Color.clear)
                            .clipShape(Circle())
                    }
                    .disabled(!canSendMessage())
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
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
        if let team = team {
            // Tous les membres de l'équipe (ou tous les collaborateurs pour la démo)
            return appData.collaborators
        } else if let c1 = collaborator1, let c2 = collaborator2 {
            // Les deux participants
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

// Pour la prévisualisation, on adapte
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(collaborator1: Collaborator.mockCollaborators(teams: Team.mockTeams)[0],
                     collaborator2: Collaborator.mockCollaborators(teams: Team.mockTeams)[1])
                .environmentObject(AppData())
        }
    }
}
