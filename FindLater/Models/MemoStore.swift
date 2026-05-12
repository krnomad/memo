import Foundation
import Observation

protocol MemoStorage {
    func load() throws -> [Memo]
    func save(_ notes: [Memo]) throws
    func reset() throws
}

struct UserDefaultsMemoStorage: MemoStorage {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "findLater.notes.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() throws -> [Memo] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder.memoDecoder.decode([Memo].self, from: data)
    }

    func save(_ notes: [Memo]) throws {
        let data = try JSONEncoder.memoEncoder.encode(notes)
        defaults.set(data, forKey: key)
    }

    func reset() throws {
        defaults.removeObject(forKey: key)
    }
}

@Observable
final class MemoStore {
    private(set) var notes: [Memo]
    var lastErrorMessage: String?

    private let storage: MemoStorage

    init(storage: MemoStorage = UserDefaultsMemoStorage(), seedIfEmpty: Bool = true) {
        self.storage = storage

        do {
            let loaded = try storage.load()
            notes = loaded.isEmpty && seedIfEmpty ? Memo.seed : loaded
            if loaded.isEmpty && seedIfEmpty {
                persist()
            }
        } catch {
            notes = seedIfEmpty ? Memo.seed : []
            lastErrorMessage = "저장된 메모를 불러오지 못했습니다."
        }
    }

    @discardableResult
    func createMemo(rawText: String, tags: [String], category: MemoCategory) -> Memo? {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let now = Date()
        let memo = Memo(
            rawText: trimmed,
            category: category,
            tags: tags,
            createdAt: now,
            updatedAt: now,
            source: .manual,
            aiStatus: .none,
            aiSuggestedTags: [],
            aiSuggestedCategory: nil,
            aiConfidence: nil,
            aiProvider: .none,
            aiError: nil
        )
        notes.insert(memo, at: 0)
        persist()
        return memo
    }

    func notes(for category: MemoCategory) -> [Memo] {
        notes.filter { $0.category == category }
    }

    func notes(tagged tag: String) -> [Memo] {
        let needle = tag.lowercased()
        return notes.filter { memo in
            memo.tags.contains { $0.lowercased() == needle }
        }
    }

    func deleteMemo(id: Memo.ID) {
        notes.removeAll { $0.id == id }
        persist()
    }

    func markMemoAIAnalysisPending(id: Memo.ID) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].aiStatus = .pending
        notes[index].aiError = nil
        notes[index].updatedAt = Date()
        persist()
    }

    func applyMemoAISuggestions(id: Memo.ID, result: MemoAIResult) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].aiStatus = .done
        notes[index].aiSuggestedTags = Memo.normalizedTags(result.tags)
        notes[index].aiSuggestedCategory = result.category
        notes[index].aiConfidence = result.confidence
        notes[index].aiProvider = result.provider
        notes[index].aiError = nil
        notes[index].updatedAt = Date()
        persist()
    }

    func markMemoAIAnalysisFailed(id: Memo.ID, error: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].aiStatus = .failed
        notes[index].aiError = error
        notes[index].updatedAt = Date()
        persist()
    }

    func acceptAISuggestions(id: Memo.ID) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        if let suggestedCategory = notes[index].aiSuggestedCategory {
            notes[index].category = suggestedCategory
        }
        notes[index].tags = Memo.normalizedTags(notes[index].tags + notes[index].aiSuggestedTags)
        notes[index].updatedAt = Date()
        persist()
    }

    func search(_ query: String) -> [Memo] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let needle = trimmed.lowercased()
        return notes.filter { memo in
            let haystack = ([memo.rawText, memo.title, memo.category.rawValue] + memo.tags)
                .joined(separator: " ")
                .lowercased()
            return haystack.contains(needle)
        }
    }

    var popularTags: [(tag: String, count: Int)] {
        var counts: [String: (display: String, count: Int)] = [:]
        for tag in notes.flatMap(\.tags) {
            let key = tag.lowercased()
            let current = counts[key] ?? (tag, 0)
            counts[key] = (current.display, current.count + 1)
        }

        return counts.values
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.display.localizedStandardCompare(rhs.display) == .orderedAscending
                }
                return lhs.count > rhs.count
            }
            .map { ($0.display, $0.count) }
    }

    var recentGroups: [(title: String, notes: [Memo])] {
        let calendar = Calendar.current
        let sorted = notes.sorted { $0.createdAt > $1.createdAt }

        let today = sorted.filter { calendar.isDateInToday($0.createdAt) }
        let week = sorted.filter { note in
            !calendar.isDateInToday(note.createdAt)
                && calendar.isDate(note.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
        }
        let older = sorted.filter { note in
            !calendar.isDateInToday(note.createdAt)
                && !calendar.isDate(note.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
        }

        return [
            ("오늘", today),
            ("이번 주", week),
            ("지난 주", older)
        ].filter { !$0.notes.isEmpty }
    }

    func resetForUITesting() {
        do {
            try storage.reset()
            notes = Memo.seed
            persist()
        } catch {
            lastErrorMessage = "테스트 데이터를 초기화하지 못했습니다."
        }
    }

    private func persist() {
        do {
            try storage.save(notes)
        } catch {
            lastErrorMessage = "메모를 저장하지 못했습니다."
        }
    }
}

extension JSONEncoder {
    static var memoEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var memoDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
