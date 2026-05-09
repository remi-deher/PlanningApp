import SwiftUI

struct TeamListView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        List {
            ForEach(appData.teams) { team in
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
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamListView()
                .environmentObject(AppData())
        }
    }
}
