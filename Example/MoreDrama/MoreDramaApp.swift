import CoreData
import MoreData
import SwiftUI

/// Example app showing how to use `Fetchable` protocol! With hopefully an interesting, silly user
/// experience too. It is a demonstration of simplicity: the whole app is less than 100 lines of code!
@MainActor
@main
struct MoreDramaApp: App {
    let dependencies = MoreDramaAppDataDependencies.default()

    init() {
        try! self.dependencies.setUp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dependencies.persistenceController.viewContext)
        }
    }
}

@MainActor
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchableRequest(
        entity: Person.self,
        filter: .none,
        sort: .name)
    private var persons: FetchedResults<Person>

    @FetchableRequest(
        entity: Statement.self,
        filter: .none,
        sort: .newest)
    private var statements: FetchedResults<Statement>

    @State private var selectedPersonID: String?
    @State private var searchQuery: String?

    var body: some View {
        NavigationView {
            List {
                ForEach(statements) { statement in
                    HStack {
                        Image(statement.thumbnailFileName, bundle: nil).resizable().frame(width: 36, height: 36)
                        Text(.init(statement.formattedContent(searchQuery: searchQuery))).padding(8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu { ForEach(["new job", "new relationship", "new pet"]) { drama in
                        Button(action: { filterForDrama(drama) }) {
                            Label(drama, systemImage: (searchQuery == drama) ? "flame.fill" : "flame")
                        }
                    } } label: {
                        Label("Search", systemImage: (searchQuery == nil) ? "flame.circle" : "flame.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu { ForEach(persons) { person in
                        Button(action: { filterForPerson(person.personID) }) {
                            Label(person.name ?? "Unknown Name", systemImage: (person.personID == selectedPersonID) ? "person.fill" : "person")
                        }
                    } } label: {
                        Label("People", systemImage: (selectedPersonID == nil) ? "person.circle" : "person.circle.fill")
                    }
                }
            }
            .refreshable { clearFilter() }
        }
    }

    func filterForDrama(_ drama: String) {
        searchQuery = (searchQuery == drama) ? nil : drama
        updateGossipQuery()
    }

    func filterForPerson(_ personID: String?) {
        selectedPersonID = (selectedPersonID == personID) ? nil : personID
        updateGossipQuery()
    }

    func clearFilter() {
        selectedPersonID = nil
        searchQuery = nil
        updateGossipQuery()
    }

    func updateGossipQuery() {
        _statements.filter = .all([
            selectedPersonID.flatMap { .toldBy($0, in: persons) },
            searchQuery.flatMap { .contains($0) }
        ].compactMap { $0 })
    }
}
