import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HeaderView()
                
                // Stat Cards
                HStack(spacing: 15) {
                    StatCard(title: "Équipes", value: "\(appData.teams.count)", icon: "person.3.fill", color: .blue)
                    StatCard(title: "Membres", value: "\(appData.collaborators.count)", icon: "person.fill", color: .green)
                }
                
                HStack(spacing: 15) {
                    StatCard(title: "Shifts Actifs", value: "\(appData.schedules.count)", icon: "clock.fill", color: .orange)
                    StatCard(title: "Alertes", value: "0", icon: "exclamationmark.triangle.fill", color: .red)
                }
                
                // Recent Schedules
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aujourd'hui")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    ForEach(appData.schedules.prefix(3)) { schedule in
                        if let collaborator = appData.collaborators.first(where: { $0.id == schedule.collaboratorId }) {
                            ScheduleRow(schedule: schedule, collaborator: collaborator)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Tableau de bord")
    }
}

// ... HeaderView, StatCard, ScheduleRow remain the same as before ...
// I'll include them to make the file complete as I'm overwriting it.

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Bonjour,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Gestionnaire")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 10)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ScheduleRow: View {
    let schedule: Schedule
    let collaborator: Collaborator
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collaborator.fullName)
                    .fontWeight(.semibold)
                Text(collaborator.role)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(formatTime(schedule.startTime))
                    .fontWeight(.bold)
                Text(formatTime(schedule.endTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(AppData())
        }
    }
}
