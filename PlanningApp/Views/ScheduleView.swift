import SwiftUI

struct ScheduleView: View {
    let teams = Team.mockTeams
    let collaborators: [Collaborator]
    let schedules: [Schedule]
    
    init() {
        self.collaborators = Collaborator.mockCollaborators(teams: teams)
        self.schedules = Schedule.mockSchedules(collaborators: collaborators)
    }
    
    var body: some View {
        List {
            ForEach(schedules) { schedule in
                if let collaborator = collaborators.first(where: { $0.id == schedule.collaboratorId }) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(collaborator.fullName)
                                .fontWeight(.bold)
                            Spacer()
                            Text(formatDate(schedule.startTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label(formatTime(schedule.startTime) + " - " + formatTime(schedule.endTime), systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if let notes = schedule.notes {
                                Text(notes)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Planning")
        .toolbar {
            Button(action: {
                // Action pour ajouter un shift
            }) {
                Image(systemName: "calendar.badge.plus")
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
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
        }
    }
}
