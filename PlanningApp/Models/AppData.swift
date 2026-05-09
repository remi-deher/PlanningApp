import Foundation

class AppData: ObservableObject {
    @Published var teams: [Team] = []
    @Published var collaborators: [Collaborator] = []
    @Published var schedules: [Schedule] = []
    
    init() {
        // Initialisation avec les données mockées existantes
        self.teams = Team.mockTeams
        self.collaborators = Collaborator.mockCollaborators(teams: teams)
        self.schedules = Schedule.mockSchedules(collaborators: collaborators)
    }
    
    func addTeam(_ team: Team) {
        teams.append(team)
    }
    
    func addCollaborator(_ collaborator: Collaborator) {
        collaborators.append(collaborator)
    }
    
    func addSchedule(_ schedule: Schedule) {
        schedules.append(schedule)
    }
}
