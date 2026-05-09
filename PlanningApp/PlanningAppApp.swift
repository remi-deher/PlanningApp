import SwiftUI

@main
struct PlanningAppApp: App {
    @State private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appData)
        }
    }
}
