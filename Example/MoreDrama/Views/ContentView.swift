import SwiftUI
import CoreData
import MoreData

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

    var body: some View {
        NavigationView {
            List {
                ForEach(persons) { person in
                    NavigationLink {
                        Text(person.name)
                        Text("Person born at \(person.birthdate, formatter: dateFormatter)")
                    } label: {
                        Text(person.name)
                        Text(person.birthdate, formatter: dateFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            Text("Select a Person")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Person(context: viewContext)
            newItem.personID = "\(persons.count + 1)"
            newItem.birthdate = .now
            newItem.name = [
                "Althea",
                "Betsy",
                "Cassidy",
                "John",
                "Stella"
            ].randomElement()!

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//#Preview {
//    ContentView().environment(\.managedObjectContext, MoreDramaAppDataDependencies.preview().persistenceController.viewContext)
//}
