import Foundation

struct NoteSearchService {
    func search(notes: [Memo], query: String, aiResult: SearchAIResult? = nil) -> [Memo] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let tokens = Self.tokens(from: trimmed)
        let aiTags = Memo.normalizedTags((aiResult?.queryTags ?? []) + (aiResult?.matchedTags ?? []))
        let categoryHints = Set(aiResult?.categoryHints ?? [])

        return notes
            .compactMap { memo -> (memo: Memo, score: Double)? in
                let score = score(memo: memo, query: trimmed, tokens: tokens, aiTags: aiTags, categoryHints: categoryHints)
                return score > 0 ? (memo, score) : nil
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.memo.createdAt > rhs.memo.createdAt
                }
                return lhs.score > rhs.score
            }
            .map(\.memo)
    }

    static func tokens(from query: String) -> [String] {
        Memo.normalizedTags(query.components(separatedBy: CharacterSet(charactersIn: " ,./\n\t·")))
    }

    private func score(
        memo: Memo,
        query: String,
        tokens: [String],
        aiTags: [String],
        categoryHints: Set<MemoCategory>
    ) -> Double {
        let normalizedQuery = Self.normalized(query)
        let allTerms = Memo.normalizedTags(tokens + aiTags + relatedTerms(for: tokens + aiTags))
        var score = 0.0

        for tag in memo.tags {
            let normalizedTag = Self.normalized(tag)
            if allTerms.contains(where: { Self.normalized($0) == normalizedTag }) {
                score += 10
            } else if allTerms.contains(where: { Self.isSimilar($0, tag) }) {
                score += 6
            }
        }

        if Self.contains(memo.title, normalizedQuery) || allTerms.contains(where: { Self.contains(memo.title, Self.normalized($0)) }) {
            score += 5
        }

        if categoryHints.contains(memo.category) || allTerms.contains(where: { Self.normalized($0) == Self.normalized(memo.category.rawValue) }) {
            score += 4
        }

        if Self.contains(memo.rawText, normalizedQuery) || allTerms.contains(where: { Self.contains(memo.rawText, Self.normalized($0)) }) {
            score += 2
        }

        score += recencyBonus(for: memo.createdAt)
        return score
    }

    private func relatedTerms(for terms: [String]) -> [String] {
        let groups = [
            ["고장", "블루스크린", "윈도우", "노트북", "문제해결"],
            ["견적", "Growise", "연락", "업무"],
            ["가족", "부모님", "개인"],
            ["AI", "메모앱", "MVP", "아이디어"]
        ]

        let normalizedTerms = Set(terms.map(Self.normalized))
        return groups.flatMap { group in
            group.contains { normalizedTerms.contains(Self.normalized($0)) } ? group : []
        }
    }

    private func recencyBonus(for date: Date) -> Double {
        let age = max(0, -date.timeIntervalSinceNow)
        switch age {
        case 0..<(60 * 60 * 24):
            return 1.5
        case 0..<(60 * 60 * 24 * 7):
            return 0.75
        default:
            return 0.25
        }
    }

    private static func contains(_ haystack: String, _ normalizedNeedle: String) -> Bool {
        normalized(haystack).contains(normalizedNeedle)
    }

    private static func isSimilar(_ left: String, _ right: String) -> Bool {
        let lhs = normalized(left)
        let rhs = normalized(right)
        guard !lhs.isEmpty, !rhs.isEmpty else { return false }
        return lhs.contains(rhs) || rhs.contains(lhs)
    }

    private static func normalized(_ value: String) -> String {
        value.lowercased().replacingOccurrences(of: " ", with: "")
    }
}
