import SwiftUI

struct AddTeamView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedColorHex: String = "#FF9500" // Default orange
    @State private var selectedIcon: String = "person.3.fill"
    
    let colors = [
        ("#FF9500", "Orange"),
        ("#5856D6", "Violet"),
        ("#34C759", "Vert"),
        ("#007AFF", "Bleu"),
        ("#FF3B30", "Rouge")
    ]
    
    let icons = ["person.3.fill", "sun.max.fill", "moon.fill", "lifepreserver.fill", "star.fill"]
    
    var body: some View {
        Form {
            Section(header: Text("Informations")) {
                TextField("Nom de l'équipe", text: $name)
            }
            
            Section(header: Text("Couleur")) {
                HStack {
                    ForEach(colors, id: \.0) { color in
                        Circle()
                            .fill(Color(hex: color.0) ?? .gray)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColorHex == color.0 ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColorHex = color.0
                            }
                    }
                }
                .padding(.vertical, 5)
            }
            
            Section(header: Text("Icône")) {
                HStack {
                    ForEach(icons, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(selectedIcon == icon ? .accentColor : .secondary)
                            .padding(10)
                            .background(selectedIcon == icon ? Color.accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedIcon = icon
                            }
                    }
                }
                .padding(.vertical, 5)
            }
            
            Button(action: {
                let newTeam = Team(name: name, colorHex: selectedColorHex, icon: selectedIcon)
                appData.addTeam(newTeam)
                dismiss()
            }) {
                Text("Enregistrer")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
            .disabled(name.isEmpty)
        }
        .navigationTitle("Nouvelle Équipe")
    }
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddTeamView()
                .environmentObject(AppData())
        }
    }
}
