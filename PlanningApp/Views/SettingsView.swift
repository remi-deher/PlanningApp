import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Gestion des données") {
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
            Section("Simulation") {
                NavigationLink(destination: AddMessageView()) {
                    Label("Simuler un message", systemImage: "message.badge.filled.fill")
                }
            }
            Section("Application") {
                LabeledContent("Version", value: "1.0.0")
            }
        }
        .navigationTitle("Paramètres")
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(AppData())
}
