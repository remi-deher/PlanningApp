import SwiftUI

struct AddMessageView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedSenderId: UUID?
    @State private var selectedReceiverId: UUID?
    @State private var content: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Expéditeur")) {
                Picker("De", selection: $selectedSenderId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(appData.collaborators) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
            }
            
            Section(header: Text("Destinataire")) {
                Picker("À", selection: $selectedReceiverId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(appData.collaborators) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
            }
            
            Section(header: Text("Message")) {
                TextField("Contenu du message", text: $content)
            }
            
            Button(action: {
                if let senderId = selectedSenderId, let receiverId = selectedReceiverId {
                    let newMessage = Message(senderId: senderId, receiverId: receiverId, content: content, timestamp: Date())
                    appData.addMessage(newMessage)
                    dismiss()
                }
            }) {
                Text("Simuler l'envoi")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
            .disabled(selectedSenderId == nil || selectedReceiverId == nil || content.isEmpty || selectedSenderId == selectedReceiverId)
        }
        .navigationTitle("Simuler un message")
    }
}

struct AddMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddMessageView()
                .environmentObject(AppData())
        }
    }
}
