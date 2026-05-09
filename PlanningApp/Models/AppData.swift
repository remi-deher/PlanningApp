import Foundation
import Observation

@Observable
class AppData {
    var teams: [Team] = []
    var collaborators: [Collaborator] = []
    var schedules: [Schedule] = []
    var messages: [Message] = []
    
    init() {
        self.teams = Team.mockTeams
        self.collaborators = Collaborator.mockCollaborators(teams: teams)
        self.schedules = Schedule.mockSchedules(collaborators: collaborators)
        self.messages = Message.mockMessages(collaborators: collaborators, teams: teams)
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
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
}
