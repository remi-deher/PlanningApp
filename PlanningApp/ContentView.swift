import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Bord", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationView {
                ScheduleView()
            }
            .tabItem {
                Label("Planning", systemImage: "calendar")
            }
            
            NavigationView {
                TeamListView()
            }
            .tabItem {
                Label("Équipes", systemImage: "person.3.fill")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
