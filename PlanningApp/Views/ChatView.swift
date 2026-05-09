import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appData: AppData
    let collaborator1: Collaborator
    let collaborator2: Collaborator
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 15) {
                    let messages = getMessages()
                    
                    ForEach(messages) { message in
                        let isFromUser1 = message.senderId == collaborator1.id
                        
                        HStack {
                            if isFromUser1 {
                                Spacer()
                            }
                            
                            VStack(alignment: isFromUser1 ? .trailing : .leading) {
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
            
            // Input Area (Simulated, as we add from settings)
            HStack {
                Text("Ajoutez des messages depuis les paramètres pour simuler la conversation.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .navigationTitle("\(collaborator2.fullName)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getMessages() -> [Message] {
        return appData.messages.filter {
            ($0.senderId == collaborator1.id && $0.receiverId == collaborator2.id) ||
            ($0.senderId == collaborator2.id && $0.receiverId == collaborator1.id)
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
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
