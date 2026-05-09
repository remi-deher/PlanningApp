import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Bord", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationStack {
                ScheduleView()
            }
            .tabItem {
                Label("Planning", systemImage: "calendar")
            }
            
            NavigationStack {
                MessagesListView()
            }
            .tabItem {
                Label("Messages", systemImage: "message.fill")
            }
            
            NavigationStack {
                TeamListView()
            }
            .tabItem {
                Label("Équipes", systemImage: "person.3.fill")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Paramètres", systemImage: "gearshape.fill")
            }
        }
        .tint(.blue) // Modern tint color for the tab bar
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
