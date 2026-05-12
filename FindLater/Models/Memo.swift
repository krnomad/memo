import Foundation

enum MemoCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case work = "업무"
    case troubleshooting = "문제해결"
    case idea = "아이디어"
    case personal = "개인"

    var id: String { rawValue }
}

enum MemoSource: String, Codable, Sendable {
    case manual
}

enum MemoAIStatus: String, Codable, CaseIterable, Sendable {
    case none
    case pending
    case done
    case failed
}

enum MemoAIProvider: String, Codable, Sendable {
    case none
    case mock
    case codexCLI = "codex-cli"
    case localLLM = "local-llm"
}

struct Memo: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var rawText: String
    var title: String
    var category: MemoCategory
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var source: MemoSource
    var aiStatus: MemoAIStatus
    var aiSuggestedTags: [String]
    var aiSuggestedCategory: MemoCategory?
    var aiConfidence: Double?
    var aiProvider: MemoAIProvider
    var aiError: String?

    init(
        id: UUID = UUID(),
        rawText: String,
        title: String? = nil,
        category: MemoCategory,
        tags: [String],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        source: MemoSource = .manual,
        aiStatus: MemoAIStatus = .none,
        aiSuggestedTags: [String] = [],
        aiSuggestedCategory: MemoCategory? = nil,
        aiConfidence: Double? = nil,
        aiProvider: MemoAIProvider = .none,
        aiError: String? = nil
    ) {
        self.id = id
        self.rawText = rawText
        self.title = title ?? Memo.makeTitle(from: rawText)
        self.category = category
        self.tags = Memo.normalizedTags(tags)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
        self.aiStatus = aiStatus
        self.aiSuggestedTags = aiSuggestedTags
        self.aiSuggestedCategory = aiSuggestedCategory
        self.aiConfidence = aiConfidence
        self.aiProvider = aiProvider
        self.aiError = aiError
    }

    enum CodingKeys: String, CodingKey {
        case id
        case rawText
        case title
        case category
        case tags
        case createdAt
        case updatedAt
        case source
        case aiStatus
        case aiSuggestedTags
        case aiSuggestedCategory
        case aiConfidence
        case aiProvider
        case aiError
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rawText = try container.decode(String.self, forKey: .rawText)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(MemoCategory.self, forKey: .category)
        tags = try container.decode([String].self, forKey: .tags)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        source = try container.decode(MemoSource.self, forKey: .source)
        aiStatus = try container.decodeIfPresent(MemoAIStatus.self, forKey: .aiStatus) ?? .none
        aiSuggestedTags = try container.decodeIfPresent([String].self, forKey: .aiSuggestedTags) ?? []
        aiSuggestedCategory = try container.decodeIfPresent(MemoCategory.self, forKey: .aiSuggestedCategory)
        aiConfidence = try container.decodeIfPresent(Double.self, forKey: .aiConfidence)
        aiProvider = try container.decodeIfPresent(MemoAIProvider.self, forKey: .aiProvider) ?? .none
        aiError = try container.decodeIfPresent(String.self, forKey: .aiError)
    }

    static func makeTitle(from rawText: String) -> String {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "제목 없는 메모" }

        if let firstLine = trimmed.split(whereSeparator: \.isNewline).first {
            let line = String(firstLine)
            if line.count > 24 {
                return String(line.prefix(24)) + "…"
            }
            return line
        }

        return trimmed
    }

    static func normalizedTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags.compactMap { tag in
            let cleaned = tag
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "#,"))
            guard !cleaned.isEmpty else { return nil }
            let key = cleaned.lowercased()
            guard !seen.contains(key) else { return nil }
            seen.insert(key)
            return cleaned
        }
    }
}

extension Memo {
    static let seed: [Memo] = [
        Memo(
            rawText: "내일 철수한테 전화하고 Growise 견적 다시 봐야함",
            title: "Growise 견적 전화",
            category: .work,
            tags: ["철수", "Growise", "견적", "연락"],
            createdAt: Date(timeIntervalSinceNow: -300),
            updatedAt: Date(timeIntervalSinceNow: -300),
            aiStatus: .pending
        ),
        Memo(
            rawText: "노트북 블루스크린 원인 찾아보기",
            title: "노트북 블루스크린",
            category: .troubleshooting,
            tags: ["노트북", "블루스크린", "윈도우"],
            createdAt: Date(timeIntervalSinceNow: -86_400),
            updatedAt: Date(timeIntervalSinceNow: -86_400)
        ),
        Memo(
            rawText: "AI 메모앱 MVP는 태그와 카테고리만 먼저 해도 괜찮을 듯",
            title: "AI 메모앱 MVP 범위",
            category: .idea,
            tags: ["AI", "메모앱", "MVP"],
            createdAt: Date(timeIntervalSinceNow: -172_800),
            updatedAt: Date(timeIntervalSinceNow: -172_800)
        ),
        Memo(
            rawText: "주말에 부모님 뵙고 자동차 공기압 확인",
            title: "주말 가족 일정",
            category: .personal,
            tags: ["가족", "자동차", "공기압"],
            createdAt: Date(timeIntervalSinceNow: -345_600),
            updatedAt: Date(timeIntervalSinceNow: -345_600)
        )
    ]
}
