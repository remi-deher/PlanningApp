import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(AppData.self) private var appData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                HeaderView()
                
                // Stat Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatCard(title: "Équipes", value: "\(appData.teams.count)", icon: "person.3.fill", gradient: LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    StatCard(title: "Membres", value: "\(appData.collaborators.count)", icon: "person.fill", gradient: LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    StatCard(title: "Shifts Actifs", value: "\(appData.schedules.count)", icon: "clock.fill", gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    StatCard(title: "Alertes", value: "0", icon: "bell.fill", gradient: LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                
                // Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Répartition par Rôle")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Chart {
                        ForEach(getRoleData(), id: \.role) { item in
                            BarMark(
                                x: .value("Rôle", item.role),
                                y: .value("Nombre", item.count)
                            )
                            .foregroundStyle(by: .value("Rôle", item.role))
                            .cornerRadius(5)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                
                // Recent Schedules
                VStack(alignment: .leading, spacing: 12) {
                    Text("Aujourd'hui")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if appData.schedules.isEmpty {
                        ContentUnavailableView("Aucun shift prévu", systemImage: "calendar.badge.clock")
                    } else {
                        ForEach(appData.schedules.prefix(3)) { schedule in
                            if let collaborator = appData.collaborators.first(where: { $0.id == schedule.collaboratorId }) {
                                ScheduleRow(schedule: schedule, collaborator: collaborator)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tableau de bord")
    }
    
    func getRoleData() -> [RoleCount] {
        let roles = appData.collaborators.map { $0.role }
        return Array(Set(roles)).map { role in
            RoleCount(role: role, count: roles.filter { $0 == role }.count)
        }
    }
}

struct RoleCount {
    let role: String
    let count: Int
}

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
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
                .frame(width: 45, height: 45)
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .padding(.vertical, 10)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.2)))
                Spacer()
            }
            Spacer()
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(height: 140)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct ScheduleRow: View {
    let schedule: Schedule
    let collaborator: Collaborator
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(collaborator.fullName).fontWeight(.semibold)
                Text(collaborator.role).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatTime(schedule.startTime)).fontWeight(.bold)
                Text(formatTime(schedule.endTime)).font(.caption).foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(AppData())
}
