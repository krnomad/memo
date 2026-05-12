import Foundation

final class InMemoryStorage: MemoStorage {
    var loadedNotes: [Memo]
    var savedNotes: [Memo]?

    init(notes: [Memo] = []) {
        loadedNotes = notes
    }

    func load() throws -> [Memo] {
        loadedNotes
    }

    func save(_ notes: [Memo]) throws {
        savedNotes = notes
        loadedNotes = notes
    }

    func reset() throws {
        loadedNotes = []
        savedNotes = nil
    }
}

@main
struct VerifyCore {
    static func main() {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)

        let created = store.createMemo(
            rawText: "  Growise 견적 다시 보기  ",
            tags: ["#견적", "Growise", "견적", ""],
            category: .work
        )

        check(created != nil, "non-empty memo should be saved")
        check(created?.rawText == "Growise 견적 다시 보기", "raw text should be trimmed")
        check(created?.tags == ["견적", "Growise"], "tags should be normalized and deduplicated")
        check(store.search("Growise").count == 1, "search should find raw text/tag")
        check(store.notes(for: .work).count == 1, "category filter should find work memo")
        check(store.notes(tagged: "견적").count == 1, "tag filter should find memo")
        check(storage.savedNotes?.count == 1, "memo should persist")
        check(store.createMemo(rawText: "   ", tags: ["x"], category: .idea) == nil, "blank memo should not save")

        print("core verification passed")
    }

    private static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        if !condition() {
            fputs("verification failed: \(message)\n", stderr)
            exit(1)
        }
    }
}
