import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Gestion des données")) {
                NavigationLink(destination: AddTeamView()) {
                    Label("Ajouter une équipe", systemImage: "person.3.badge.plus")
                }
                
                NavigationLink(destination: AddCollaboratorView()) {
                    Label("Ajouter un collaborateur", systemImage: "person.badge.plus")
                }
                
                NavigationLink(destination: AddScheduleView()) {
                    Label("Planifier un créneau", systemImage: "calendar.badge.plus")
                }
            }
            
            Section(header: Text("Simulation")) {
                NavigationLink(destination: AddMessageView()) {
                    Label("Simuler un message", systemImage: "message.badge.filled.fill")
                }
            }
            
            Section(header: Text("Application")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Paramètres")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
