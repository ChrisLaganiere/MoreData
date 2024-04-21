import SwiftUI

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
