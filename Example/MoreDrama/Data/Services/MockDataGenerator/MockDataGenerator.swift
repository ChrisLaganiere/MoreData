import CoreData
import MoreData

/// Silly helper class which fills in database with a stream of sample data!
@MainActor
final class MockDataGenerator {

    private let persistenceController: CoreDataPersistenceController

    private var timer: Timer?

    init(persistenceController: CoreDataPersistenceController) {
        self.persistenceController = persistenceController
    }

    func startGenerating() {
        timer = .scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            Task {
                do {
                    try await self.generatePeopleIfNeeded()
                    try await self.generateStatement()
                }
                catch {
                    print("something went wrong in mock data generator: \(error)")
                }
            }
        })
    }

    func stopGenerating() {
        timer?.invalidate()
    }

    private func generatePeopleIfNeeded() async throws {
        try await persistenceController.performBackgroundTask { moc in

            guard try Person.count(moc: moc) == 0 else {
                return
            }

            let person1 = Person(context: moc)
            person1.name = "Alpha Allie"
            person1.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 24)
            person1.personID = UUID().uuidString
            person1.avatarFileName = "clue-characters-6"

            let person2 = Person(context: moc)
            person2.name = "Bookish Betty"
            person2.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 28)
            person2.personID = UUID().uuidString
            person2.avatarFileName = "clue-characters-3"

            let person3 = Person(context: moc)
            person3.name = "Catty Cathy"
            person3.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 21)
            person3.personID = UUID().uuidString
            person3.avatarFileName = "clue-characters-1"

            let person4 = Person(context: moc)
            person4.name = "Daring Darion"
            person4.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 32)
            person4.personID = UUID().uuidString
            person4.avatarFileName = "clue-characters-2"

            let person5 = Person(context: moc)
            person5.name = "Emotional Elijah"
            person5.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 32)
            person5.personID = UUID().uuidString
            person5.avatarFileName = "clue-characters-4"

            let person6 = Person(context: moc)
            person6.name = "Fratty Fred"
            person6.birthdate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 32)
            person6.personID = UUID().uuidString
            person6.avatarFileName = "clue-characters-5"

            try moc.save()
        }
    }

    private func generateStatement() async throws {
        try await persistenceController.performBackgroundTask { moc in
            let speaker = try Person.all(moc: moc)
                .randomElement()!

            let listeners = try Person.all(moc: moc)
                .shuffled()
                .prefix([1, 2, 3].randomElement()!)

            let content = [
                "Jessica's in a new relationship with the captain of the soccer team—scandalous!",
                "Brian just got a new job at the ice cream shop, but he ate all the samples and got fired.",
                "Sarah’s new pet hamster escaped during math class, and now it's somewhere in the school.",
                "Emily's in a new relationship with the exchange student, and everyone’s talking about it.",
                "Kyle got a new job at the mall, but he quit after one day because it was too \"corporate.\"",
                "Sophia's new pet parrot keeps repeating all the gossip she hears at school—awkward!",
                "Mike's in a new relationship with his best friend's sister, and things just got complicated.",
                "Lily got a new job at the coffee shop, but she can't stop spilling the drinks.",
                "Jake's new pet ferret escaped during gym class, and now it's the school mascot.",
                "Ashley's in a new relationship with her ex's twin brother—can you believe it?",
                "Eric just got a new job at the movie theater, but he keeps giving out free popcorn.",
                "Rachel's new pet cat keeps stealing her homework—at least that’s her excuse!",
                "Daniel's in a new relationship with his lab partner, and their chemistry is undeniable.",
                "Megan got a new job at the local bakery, but she keeps eating the cupcakes.",
                "Tyler’s new pet snake scared the principal—now it’s banned from school.",
                "Olivia's in a new relationship with the debate team captain, and now they argue about everything.",
                "Matt got a new job at the arcade, but he spends all his time playing the games.",
                "Chloe's new pet bunny chewed through her math book, and now she’s failing the class.",
                "Alex's in a new relationship with his neighbor, but they’re keeping it a secret—shhh!",
                "Nick got a new job at the pizza place, but he burned every pizza on his first day.",
                "Sam’s new pet turtle won’t stop following him around school—it's kind of adorable.",
                "Ella's in a new relationship with the school’s star quarterback—everyone’s jealous.",
                "Ben just got a new job at the library, but he keeps shushing the wrong people.",
                "Ava’s new pet goldfish is somehow the most popular \"student\" in school.",
                "Jason's in a new relationship with the art teacher’s daughter—it's like a soap opera.",
                "Mia got a new job at the flower shop, but she’s allergic to pollen—yikes!",
                "Luke’s new pet frog escaped into the cafeteria—now it's causing chaos.",
                "Grace is in a new relationship with the student council president, and everyone’s watching.",
                "Ryan just got a new job at the gym, but he spends all his time posing in the mirrors.",
                "Zoe’s new pet guinea pig is somehow best friends with her cat—how did that happen?",
                "Katie’s in a new relationship with the school’s biggest prankster—what could go wrong?",
                "Chris got a new job at the bakery, but he accidentally baked a cake with salt instead of sugar.",
                "Emma’s new pet puppy keeps stealing her shoes, and now she’s always late to class.",
                "Brandon’s in a new relationship with his ex’s best friend—drama alert!",
                "Hannah got a new job at the bookstore, but she’s always lost in the romance novels.",
                "Sean’s new pet iguana somehow ended up in the principal’s office—oops!",
                "Madison’s in a new relationship with her math tutor—talk about extra credit!",
                "Ethan got a new job at the smoothie shop, but he blends everything wrong.",
                "Leah’s new pet kitten follows her to school every day—it's the unofficial mascot now.",
                "Josh is in a new relationship with his lab partner, but they argue about every experiment.",
                "Lauren got a new job at the frozen yogurt shop, but she keeps mixing up the flavors.",
                "Dylan’s new pet bird sings during his online classes—his teacher isn’t a fan.",
                "Amber’s in a new relationship with her ex’s twin—did she get confused?",
                "Marcus got a new job at the pet store, but he’s afraid of birds—awkward.",
                "Paige’s new pet rabbit chewed through her internet cable—no more late-night gaming."
            ].randomElement()!

            let statement = Statement(context: moc)
            statement.by = speaker
            statement.to = NSSet(array: Array(listeners))
            statement.time = .now
            statement.content = content
            statement.statementID = UUID().uuidString

            try moc.save()
        }
    }
}
