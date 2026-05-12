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

    func testNaturalLanguageSearchFindsTroubleshootingMemo() {
        let service = NoteSearchService()
        let aiResult = SearchAIResult(
            queryTags: ["노트북", "고장"],
            matchedTags: ["노트북", "블루스크린", "윈도우"],
            categoryHints: [.troubleshooting],
            confidence: 0.7,
            provider: .mock
        )

        let results = service.search(
            notes: Memo.seed,
            query: "지난번 노트북 고장 관련해서 적어둔 거",
            aiResult: aiResult
        )

        XCTAssertEqual(results.first?.title, "노트북 블루스크린")
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

    func testDeleteMemoRemovesNoteAndPersists() throws {
        let storage = InMemoryStorage(notes: Memo.seed)
        let store = MemoStore(storage: storage, seedIfEmpty: false)
        let memo = try XCTUnwrap(store.notes.first)

        store.deleteMemo(id: memo.id)

        XCTAssertFalse(store.notes.contains { $0.id == memo.id })
        XCTAssertFalse(try XCTUnwrap(storage.savedNotes).contains { $0.id == memo.id })
    }

    func testApplyMockAIResultStoresSuggestionsAndPersists() async throws {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)
        let memo = try XCTUnwrap(store.createMemo(
            rawText: "내일 철수한테 전화하고 Growise 견적 다시 봐야함",
            tags: [],
            category: .work
        ))
        var result = try await AIService(adapter: MockAIAdapter()).extractMemoMetadata(text: memo.rawText)
        result.title = "AI가 제안한 제목"

        store.markMemoAIAnalysisPending(id: memo.id)
        store.applyMemoAISuggestions(id: memo.id, result: result)

        let updated = try XCTUnwrap(store.notes.first)
        XCTAssertEqual(updated.title, memo.title)
        XCTAssertEqual(updated.aiStatus, .done)
        XCTAssertEqual(updated.aiProvider, .mock)
        XCTAssertEqual(updated.aiSuggestedCategory, .work)
        XCTAssertTrue(updated.aiSuggestedTags.contains("Growise"))
        XCTAssertEqual(storage.savedNotes?.first?.aiStatus, .done)
    }

    func testAIAnalysisFailureKeepsManualMemoDataAndPersists() throws {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)
        let memo = try XCTUnwrap(store.createMemo(
            rawText: "수동 태그는 유지되어야 함",
            tags: ["수동"],
            category: .idea
        ))

        store.markMemoAIAnalysisPending(id: memo.id)
        store.markMemoAIAnalysisFailed(id: memo.id, error: "backend_unreachable")

        let updated = try XCTUnwrap(store.notes.first)
        XCTAssertEqual(updated.aiStatus, .failed)
        XCTAssertEqual(updated.aiError, "backend_unreachable")
        XCTAssertEqual(updated.tags, ["수동"])
        XCTAssertEqual(updated.category, .idea)
        XCTAssertEqual(storage.savedNotes?.first?.aiStatus, .failed)
    }

    func testAcceptAISuggestionsMergesTagsAndAppliesCategory() throws {
        let storage = InMemoryStorage()
        let store = MemoStore(storage: storage, seedIfEmpty: false)
        let memo = try XCTUnwrap(store.createMemo(
            rawText: "노트북 블루스크린 원인 찾아보기",
            tags: ["노트북"],
            category: .work
        ))
        let result = MemoAIResult(
            title: "노트북 블루스크린",
            category: .troubleshooting,
            tags: ["노트북", "블루스크린", "윈도우"],
            entities: .empty,
            importance: .medium,
            isTask: true,
            confidence: 0.72,
            provider: .mock
        )

        store.applyMemoAISuggestions(id: memo.id, result: result)
        XCTAssertEqual(store.notes.first?.category, .work)
        XCTAssertEqual(store.notes.first?.tags, ["노트북"])

        store.acceptAISuggestions(id: memo.id)

        let updated = try XCTUnwrap(store.notes.first)
        XCTAssertEqual(updated.category, .troubleshooting)
        XCTAssertEqual(updated.tags, ["노트북", "블루스크린", "윈도우"])
        XCTAssertEqual(storage.savedNotes?.first?.category, .troubleshooting)
    }

    func testMemoDecodesOldAIReadyPayloadWithoutNewFields() throws {
        let id = UUID()
        let json = """
        {
          "id": "\(id.uuidString)",
          "rawText": "기존 저장 메모",
          "title": "기존 저장 메모",
          "category": "업무",
          "tags": ["기존"],
          "createdAt": "2026-05-13T00:00:00Z",
          "updatedAt": "2026-05-13T00:00:00Z",
          "source": "manual",
          "aiStatus": "none",
          "aiSuggestedTags": [],
          "aiSuggestedCategory": null
        }
        """

        let memo = try JSONDecoder.memoDecoder.decode(Memo.self, from: Data(json.utf8))

        XCTAssertEqual(memo.id, id)
        XCTAssertEqual(memo.aiProvider, .none)
        XCTAssertNil(memo.aiConfidence)
        XCTAssertNil(memo.aiError)
    }

    func testAIConfigurationParsesProviderAndBackendURL() throws {
        let configuration = AIConfiguration(arguments: [
            "FindLater",
            "--ai-provider",
            "backend",
            "--ai-backend-url",
            "http://127.0.0.1:8989",
            "--ai-diagnostics"
        ])

        XCTAssertEqual(configuration.provider, .backendCodex)
        XCTAssertEqual(configuration.backendBaseURL, URL(string: "http://127.0.0.1:8989"))
        XCTAssertTrue(configuration.diagnosticsEnabled)
        XCTAssertTrue(configuration.makeAdapter() is BackendCodexAdapter)
    }

    func testLocalLLMAdapterIsExplicitlyUnimplemented() async {
        do {
            _ = try await LocalLLMAdapter().extractMemoMetadata(text: "메모")
            XCTFail("LocalLLMAdapter should not be implemented yet.")
        } catch let error as AIServiceError {
            XCTAssertEqual(error, .notImplemented)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
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
