import SwiftUI

struct TeamListView: View {
    @Environment(AppData.self) private var appData
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if appData.teams.isEmpty {
                    ContentUnavailableView("Aucune équipe", systemImage: "person.3.fill", description: Text("Ajoutez des équipes depuis les paramètres."))
                        .padding(.top, 40)
                } else {
                    ForEach(appData.teams) { team in
                        HStack(spacing: 15) {
                            Image(systemName: team.icon)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(team.color)
                                .clipShape(Circle())
                                .shadow(color: team.color.opacity(0.4), radius: 5, x: 0, y: 3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(team.name).fontWeight(.semibold)
                                let memberCount = appData.collaborators.filter { $0.teamId == team.id }.count
                                Text("\(memberCount) membre\(memberCount > 1 ? "s" : "")")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary).font(.caption).fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Équipes")
    }
}

#Preview {
    NavigationStack { TeamListView() }
        .environment(AppData())
}
