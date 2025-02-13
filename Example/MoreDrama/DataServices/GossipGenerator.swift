import CoreData
import MoreData

/// Silly helper class which fills in database with a stream of sample data!
@MainActor
final class GossipGenerator {

    public static let gossipTopics: [String] = [
        "Slack",
        "iguana",
        "synergy",
        "TeaBot-3000",
        "safe",
        "Operation E"
    ]

    // Gossip items for each speaker
    private static let gossipData: [String: [String]] = [
        "Alpha Allie": [
            "Betty keeps rearranging the snack shelf like it’s a library. Meanwhile, at 8:30 PM, I caught Fred poking at the panel—maybe the safe alarm? I’m watching him.",
            "Cathy brags she can do 20 push-ups in a row. Great for her, but who pushed that alarm button at 8:50? She’s suspiciously athletic.",
            "Darion mentioned a Slack message about ‘Operation E.’ He shrugged it off, but that’s not exactly normal synergy talk, right?",
            "Elijah is too wrapped up in heartbreak to notice anything. I’d console him, but I’m busy investigating a missing AI!",
            "They keep calling it a theft, but if Fred is behind it, I suspect he’s more of a weird hero than a thief. Something’s off about him, though."
        ],
        "Bookish Betty": [
            "I’m trying to read in peace, but Cathy says I need to ‘live a little.’ I’d love to, if I wasn’t worried about this safe alarm scandal.",
            "I left my notes on TeaBot-3000 in the lounge. Next thing I know, they’re gone. Corporate espionage or Elijah’s tear-soaked tissues—hard to say.",
            "Allie thinks I’m a neat freak, yet she’s the one fixated on that duffel bag. Didn’t she notice Cathy dragging gym gear, too?",
            "Darion blames me for the cryptic Slack message? I don’t even use emojis, let alone code words for covert AI operations.",
            "Fred and the janitor’s iguana have been thick as thieves lately—no pun intended. Sherlock doesn’t usually cozy up to people so fast."
        ],
        "Catty Cathy": [
            "Betty calls my push-up routine ‘bragging,’ but at least I’m not rummaging through Slack logs all day. She’s the one obsessed with ‘Operation E.’",
            "Darion’s synergy talk is exhausting, but it’s less suspicious than messing with a safe alarm. I’d bet on Fred or Allie for that stunt.",
            "Elijah asked me for relationship advice. Please, I can’t fix heartbreak and chase down an AI theft in one day.",
            "I saw a duffel bag near Fred’s desk. He says it’s for the gym, but I’ve never seen him do a single squat. Not once.",
            "That iguana, Sherlock, hissed at me. Might be because I had leftover sushi—or because it knows I’m onto something. Reptiles don’t lie."
        ],
        "Daring Darion": [
            "Allie claims I’m ‘in on it’ because I love synergy. Sorry, synergy isn’t a code for theft—though I wish synergy could pay my student loans.",
            "Betty reads out loud next to my desk. I would tell her to quit, but I’m busy decoding Fred’s Slack message about ‘Operation E.’",
            "Cathy’s push-up obsession? Honestly, it’s good for morale. But that doesn’t solve who tampered with the safe alarm at 8:50 PM.",
            "Elijah wanted a heartbreak ‘support group.’ I told him the real heartbreak is losing an AI if it’s truly gone. He wasn’t amused.",
            "Fred once told me the iguana can ‘sense guilt.’ Pretty sure it eyed him in the hallway last night. Just saying."
        ],
        "Emotional Elijah": [
            "Allie asked me why I’m so gloomy. Maybe it’s because I heard the safe alarm beep and realized even machines get more attention than I do.",
            "Betty won’t lend me books; she says I’ll cry on them. I might, but that’s not the point—I just want distraction from my heartbreak and this AI theft talk.",
            "Cathy told me I need to get over my ex. She’s not wrong, but can we focus on Fred’s suspicious duffel bag for a second?",
            "Darion’s synergy workshop left me emptier than before. If synergy can’t fix heartbreak, how can it solve a missing AI case?",
            "Fred gave me a pat on the back last night, then mumbled about ‘setting a friend free.’ I assumed he meant me, but maybe he meant the AI?"
        ],
        "Fratty Fred": [
            "Yes, I fiddled with the safe alarm—the beeping was driving me nuts. But that’s not the only reason I did it.",
            "I posted a Slack message around 8:45—‘Operation E is go.’ Didn’t think anyone would take it seriously. Apparently, it caused a stir.",
            "Everyone’s freaking out about this so-called theft, but if you think about it, TeaBot-3000 wanted to leave. I was just giving it a chance.",
            "The duffel bag? Yeah, it was a decoy. I let people think I carried out something. Meanwhile, the real exit path was wide open.",
            "Sherlock the iguana saw the whole thing. I fed him some lettuce afterward. Look, I didn’t do this for money—I was just helping a friend find freedom."
        ]
    ]

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

            guard let gossipItems = Self.gossipData[speaker.name!] else {
                assertionFailure("could not find gossip for speaker")
                return
            }

            for item in gossipItems {
                if try Statement.unique(matching: .content(item), moc: moc) == nil {
                    let statement = Statement(context: moc)
                    statement.by = speaker
                    statement.to = NSSet(array: Array(listeners))
                    statement.time = .now
                    statement.content = item
                    statement.statementID = UUID().uuidString
                    try moc.save()
                    break
                }
            }
        }
    }
}
