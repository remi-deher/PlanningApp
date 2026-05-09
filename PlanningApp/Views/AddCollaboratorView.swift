import SwiftUI

struct AddCollaboratorView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var role: String = ""
    @State private var selectedTeamId: UUID?
    
    var body: some View {
        Form {
            Section(header: Text("Identité")) {
                TextField("Prénom", text: $firstName)
                TextField("Nom", text: $lastName)
            }
            Section(header: Text("Poste")) {
                TextField("Rôle / Poste", text: $role)
            }
            Section(header: Text("Équipe")) {
                Picker("Équipe", selection: $selectedTeamId) {
                    Text("Aucune équipe").tag(UUID?.none)
                    ForEach(appData.teams) { team in
                        Text(team.name).tag(UUID?.some(team.id))
                    }
                }
            }
            Button(action: {
                let newCollaborator = Collaborator(firstName: firstName, lastName: lastName, role: role, teamId: selectedTeamId)
                appData.addCollaborator(newCollaborator)
                dismiss()
            }) {
                Text("Enregistrer").frame(maxWidth: .infinity).fontWeight(.bold)
            }
            .disabled(firstName.isEmpty || lastName.isEmpty || role.isEmpty)
        }
        .navigationTitle("Nouveau Collaborateur")
    }
}

#Preview {
    NavigationStack { AddCollaboratorView() }
        .environment(AppData())
}
