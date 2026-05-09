import SwiftUI

struct ScheduleView: View {
    @Environment(AppData.self) private var appData
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal Date Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<7) { day in
                        let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
                        DateCard(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture { selectedDate = date }
                    }
                }
                .padding()
            }
            .background(Color(.secondarySystemGroupedBackground))
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    if appData.schedules.isEmpty {
                        ContentUnavailableView(
                            "Aucun shift prévu",
                            systemImage: "calendar.badge.plus",
                            description: Text("Ajoutez des shifts depuis les paramètres.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(appData.schedules) { schedule in
                            if let collaborator = appData.collaborators.first(where: { $0.id == schedule.collaboratorId }) {
                                ScheduleCard(schedule: schedule, collaborator: collaborator)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Planning")
    }
}

struct DateCard: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formatDay(date))
                .font(.caption2).fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .secondary)
            Text(formatDateNumber(date))
                .font(.title3).fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 55, height: 70)
        .background(isSelected ?
            LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.02), radius: 5, x: 0, y: 3)
    }
    
    func formatDay(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
    func formatDateNumber(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }
}

struct ScheduleCard: View {
    let schedule: Schedule
    let collaborator: Collaborator
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collaborator.fullName).font(.headline)
                        Text(collaborator.role).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(formatDate(schedule.startTime))
                        .font(.caption2).foregroundColor(.secondary)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(.systemBackground))
                        .clipShape(Capsule())
                }
                HStack {
                    Label(formatTime(schedule.startTime) + " - " + formatTime(schedule.endTime), systemImage: "clock")
                        .font(.subheadline).fontWeight(.semibold)
                    Spacer()
                    if let notes = schedule.notes {
                        Text(notes).font(.caption2)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMM"
        return f.string(from: date)
    }
    func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack { ScheduleView() }
        .environment(AppData())
}
