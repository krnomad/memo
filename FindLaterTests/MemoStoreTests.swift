import XCTest
@testable import FindLater

final class MemoStoreTests: XCTestCase {
    func testCreateMemoTrimsTextNormalizesTagsAndPersists() throws {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)

        let memo = try XCTUnwrap(store.createMemo(
            rawText: "  Growise 견적 다시 보기  ",
            tags: [" #견적", "Growise", "견적", ""],
            category: .work
        ))

        XCTAssertEqual(memo.rawText, "Growise 견적 다시 보기")
        XCTAssertEqual(memo.tags, ["견적", "Growise"])
        XCTAssertEqual(memo.category, .work)
        XCTAssertEqual(memo.source, .manual)
        XCTAssertEqual(memo.aiStatus, .none)
        XCTAssertEqual(storage.savedNotes?.first?.id, memo.id)
    }

    func testSearchFindsRawTextCategoryAndTags() {
        let storage = InMemoryStorage(notes: Memo.seed)
        let store = MemoStore(storage: storage, seedIfEmpty: false)

        XCTAssertEqual(store.search("Growise").first?.category, .work)
        XCTAssertEqual(store.search("블루스크린").first?.category, .troubleshooting)
        XCTAssertEqual(store.search("공기압").first?.category, .personal)
        XCTAssertEqual(store.search("메모앱").first?.category, .idea)
    }

    func testBrowseFiltersByCategoryAndTag() {
        let storage = InMemoryStorage(notes: Memo.seed)
        let store = MemoStore(storage: storage, seedIfEmpty: false)

        XCTAssertEqual(store.notes(for: .work).count, 1)
        XCTAssertEqual(store.notes(tagged: "Growise").first?.title, "Growise 견적 전화")
    }

    func testEmptyMemoIsNotSaved() {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)

        XCTAssertNil(store.createMemo(rawText: "   ", tags: ["임시"], category: .idea))
        XCTAssertTrue(store.notes.isEmpty)
        XCTAssertNil(storage.savedNotes)
    }
}

private final class InMemoryStorage: MemoStorage {
    private var loadedNotes: [Memo]
    private(set) var savedNotes: [Memo]?

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
