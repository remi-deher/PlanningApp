import SwiftUI

struct AddScheduleView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCollaboratorId: UUID?
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600)
    @State private var notes: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Collaborateur")) {
                Picker("Collaborateur", selection: $selectedCollaboratorId) {
                    Text("Sélectionner").tag(UUID?.none)
                    ForEach(appData.collaborators) { collaborator in
                        Text(collaborator.fullName).tag(UUID?.some(collaborator.id))
                    }
                }
            }
            Section(header: Text("Horaires")) {
                DatePicker("Début", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Fin", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
            }
            Section(header: Text("Notes")) {
                TextField("Notes (facultatif)", text: $notes)
            }
            Button(action: {
                if let collaboratorId = selectedCollaboratorId {
                    let newSchedule = Schedule(collaboratorId: collaboratorId, startTime: startTime, endTime: endTime, notes: notes.isEmpty ? nil : notes)
                    appData.addSchedule(newSchedule)
                    dismiss()
                }
            }) {
                Text("Enregistrer").frame(maxWidth: .infinity).fontWeight(.bold)
            }
            .disabled(selectedCollaboratorId == nil || startTime >= endTime)
        }
        .navigationTitle("Planifier un créneau")
    }
}

#Preview {
    NavigationStack { AddScheduleView() }
        .environment(AppData())
}
