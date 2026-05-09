import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Bord", systemImage: "square.grid.2x2.fill") {
                NavigationStack {
                    DashboardView()
                }
            }
            Tab("Planning", systemImage: "calendar") {
                NavigationStack {
                    ScheduleView()
                }
            }
            Tab("Messages", systemImage: "message.fill") {
                NavigationStack {
                    MessagesListView()
                }
            }
            Tab("Équipes", systemImage: "person.3.fill") {
                NavigationStack {
                    TeamListView()
                }
            }
            Tab("Paramètres", systemImage: "gearshape.fill") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .environment(AppData())
}
