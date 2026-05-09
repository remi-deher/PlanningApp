import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appData: AppData
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal Date Picker (Mock)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<7) { day in
                        let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
                        DateCard(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
                .padding()
            }
            .background(Color(.secondarySystemGroupedBackground))
            
            // Schedule List
            ScrollView {
                LazyVStack(spacing: 15) {
                    let filteredSchedules = appData.schedules // In a real app, filter by selectedDate
                    
                    if filteredSchedules.isEmpty {
                        ContentUnavailableView(
                            "Aucun shift prévu",
                            systemImage: "calendar.badge.plus",
                            description: Text("Ajoutez des shifts depuis les paramètres.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredSchedules) { schedule in
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
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(formatDateNumber(date))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 55, height: 70)
        .background(isSelected ? LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color(.systemBackground)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.02), radius: 5, x: 0, y: 3)
    }
    
    func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    func formatDateNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct ScheduleCard: View {
    let schedule: Schedule
    let collaborator: Collaborator
    
    var body: some View {
        HStack(spacing: 0) {
            // Color indicator
            Rectangle()
                .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collaborator.fullName)
                            .font(.headline)
                        Text(collaborator.role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatDate(schedule.startTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground))
                        .clipShape(Capsule())
                }
                
                HStack {
                    Label(formatTime(schedule.startTime) + " - " + formatTime(schedule.endTime), systemImage: "clock")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let notes = schedule.notes {
                        Text(notes)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleView()
                .environmentObject(AppData())
        }
    }
}
