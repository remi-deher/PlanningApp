import SwiftUI

struct AddMessageView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedSenderId: UUID?
    @State private var isTeamMessage: Bool = false
    @State private var selectedReceiverId: UUID?
    @State private var selectedTeamId: UUID?
    @State private var content: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Type de message")) {
                Picker("Type", selection: $isTeamMessage) {
                    Text("Privé").tag(false)
                    Text("Équipe").tag(true)
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Expéditeur")) {
                Picker("De", selection: $selectedSenderId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(appData.collaborators) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
            }
            if isTeamMessage {
                Section(header: Text("Équipe Destinataire")) {
                    Picker("À l'équipe", selection: $selectedTeamId) {
                        Text("Sélectionner").tag(UUID?.none)
                        ForEach(appData.teams) { team in
                            Text(team.name).tag(UUID?.some(team.id))
                        }
                    }
                }
            } else {
                Section(header: Text("Destinataire")) {
                    Picker("À", selection: $selectedReceiverId) {
                        Text("Sélectionner").tag(UUID?.none)
                        ForEach(appData.collaborators) { collaborator in
                            Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                        }
                    }
                }
            }
            Section(header: Text("Message")) {
                TextField("Contenu du message", text: $content)
            }
            Button(action: {
                if let senderId = selectedSenderId {
                    if isTeamMessage, let teamId = selectedTeamId {
                        appData.addMessage(Message(senderId: senderId, teamId: teamId, content: content, timestamp: Date()))
                        dismiss()
                    } else if !isTeamMessage, let receiverId = selectedReceiverId {
                        appData.addMessage(Message(senderId: senderId, receiverId: receiverId, content: content, timestamp: Date()))
                        dismiss()
                    }
                }
            }) {
                Text("Simuler l'envoi").frame(maxWidth: .infinity).fontWeight(.bold)
            }
            .disabled(
                selectedSenderId == nil ||
                (isTeamMessage && selectedTeamId == nil) ||
                (!isTeamMessage && selectedReceiverId == nil) ||
                content.isEmpty ||
                (!isTeamMessage && selectedSenderId == selectedReceiverId)
            )
        }
        .navigationTitle("Simuler un message")
    }
}

#Preview {
    NavigationStack { AddMessageView() }
        .environment(AppData())
}
