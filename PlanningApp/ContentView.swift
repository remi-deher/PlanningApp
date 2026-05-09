import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Bord", systemImage: "square.grid.2x2.fill") {
                NavigationStack { DashboardView() }
            }
            Tab("Planning", systemImage: "calendar") {
                NavigationStack { ScheduleView() }
            }
            Tab("Messages", systemImage: "message.fill") {
                NavigationStack { MessagesListView() }
            }
            Tab("Équipes", systemImage: "person.3.fill") {
                NavigationStack { TeamListView() }
            }
            Tab("Paramètres", systemImage: "gearshape.fill") {
                NavigationStack { SettingsView() }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(.blue)
        // Ensures the TabView background (and its child views) extends to the full screen
        // including behind the Dynamic Island, status bar, and home indicator on iPhone 16 Pro Max
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    ContentView()
        .environment(AppData())
}
