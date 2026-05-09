import SwiftUI

struct TeamListView: View {
    let teams = Team.mockTeams
    
    var body: some View {
        List {
            ForEach(teams) { team in
                HStack(spacing: 15) {
                    Image(systemName: team.icon)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(team.color)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(team.name)
                            .fontWeight(.semibold)
                        Text("Cliquez pour voir les membres")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Équipes")
        .toolbar {
            Button(action: {
                // Action pour ajouter une équipe
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamListView()
        }
    }
}
