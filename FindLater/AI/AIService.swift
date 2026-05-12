import Foundation

enum MemoImportance: String, Codable, Equatable, Sendable {
    case low
    case medium
    case high
}

struct MemoEntities: Codable, Equatable, Sendable {
    var people: [String]
    var projects: [String]
    var dates: [String]

    static let empty = MemoEntities(people: [], projects: [], dates: [])
}

struct MemoAIResult: Codable, Equatable, Sendable {
    var title: String
    var category: MemoCategory
    var tags: [String]
    var entities: MemoEntities
    var importance: MemoImportance
    var isTask: Bool
    var confidence: Double
    var provider: MemoAIProvider
}

struct SearchAIResult: Codable, Equatable, Sendable {
    var queryTags: [String]
    var matchedTags: [String]
    var categoryHints: [MemoCategory]
    var confidence: Double
    var provider: MemoAIProvider
}

enum AIServiceError: Error, Equatable {
    case backendFailed
    case invalidResponse
    case notImplemented
}

protocol AIAdapter {
    func extractMemoMetadata(text: String) async throws -> MemoAIResult
    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult
}

struct AIService {
    private let adapter: AIAdapter

    init(configuration: AIConfiguration = .current) {
        self.adapter = configuration.makeAdapter()
    }

    init(adapter: AIAdapter) {
        self.adapter = adapter
    }

    func extractMemoMetadata(text: String) async throws -> MemoAIResult {
        try await adapter.extractMemoMetadata(text: text)
    }

    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult {
        try await adapter.extractSearchTags(query: query, knownTags: knownTags)
    }
}

struct MockAIAdapter: AIAdapter {
    func extractMemoMetadata(text: String) async throws -> MemoAIResult {
        let category = inferCategory(from: text)
        let tags = inferTags(from: text, category: category)

        return MemoAIResult(
            title: Memo.makeTitle(from: text),
            category: category,
            tags: tags,
            entities: MemoEntities(
                people: text.contains("철수") ? ["철수"] : [],
                projects: text.localizedCaseInsensitiveContains("Growise") ? ["Growise"] : [],
                dates: text.contains("내일") ? ["내일"] : []
            ),
            importance: text.contains("내일") ? .medium : .low,
            isTask: text.contains("해야") || text.contains("확인") || text.contains("보기"),
            confidence: 0.72,
            provider: .mock
        )
    }

    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult {
        let queryTags = Memo.normalizedTags(query.components(separatedBy: CharacterSet(charactersIn: " ,·")))
        let matchedTags = knownTags.filter { tag in
            queryTags.contains { queryTag in
                tag.localizedCaseInsensitiveContains(queryTag)
                    || queryTag.localizedCaseInsensitiveContains(tag)
                    || areRelated(queryTag, tag)
            }
        }

        return SearchAIResult(
            queryTags: queryTags,
            matchedTags: matchedTags,
            categoryHints: query.localizedCaseInsensitiveContains("고장") ? [.troubleshooting] : [],
            confidence: matchedTags.isEmpty ? 0.35 : 0.7,
            provider: .mock
        )
    }

    private func areRelated(_ left: String, _ right: String) -> Bool {
        let groups = [
            ["고장", "블루스크린", "윈도우", "노트북", "문제해결"],
            ["견적", "Growise", "연락", "업무"],
            ["가족", "부모님", "개인"],
            ["AI", "메모앱", "MVP", "아이디어"]
        ]

        return groups.contains { group in
            group.contains { $0.localizedCaseInsensitiveCompare(left) == .orderedSame }
                && group.contains { $0.localizedCaseInsensitiveCompare(right) == .orderedSame }
        }
    }

    private func inferCategory(from text: String) -> MemoCategory {
        if text.localizedCaseInsensitiveContains("블루스크린") || text.localizedCaseInsensitiveContains("고장") {
            return .troubleshooting
        }
        if text.localizedCaseInsensitiveContains("MVP") || text.localizedCaseInsensitiveContains("아이디어") {
            return .idea
        }
        if text.localizedCaseInsensitiveContains("부모님") || text.localizedCaseInsensitiveContains("주말") {
            return .personal
        }
        return .work
    }

    private func inferTags(from text: String, category: MemoCategory) -> [String] {
        var tags: [String] = []
        for candidate in ["철수", "Growise", "견적", "연락", "노트북", "블루스크린", "윈도우", "AI", "메모앱", "MVP", "가족", "자동차", "공기압"] {
            if text.localizedCaseInsensitiveContains(candidate) {
                tags.append(candidate)
            }
        }
        if tags.isEmpty {
            tags.append(category.rawValue)
        }
        return Memo.normalizedTags(tags)
    }
}

struct BackendCodexAdapter: AIAdapter {
    let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = AIConfiguration.defaultBackendBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func extractMemoMetadata(text: String) async throws -> MemoAIResult {
        let request = try makeJSONRequest(
            path: "/api/ai/memo/analyze",
            body: MemoAnalysisRequest(text: text, locale: "ko-KR")
        )
        return try await decodeResponse(MemoAIResult.self, from: request)
    }

    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult {
        let request = try makeJSONRequest(
            path: "/api/ai/search/extract-tags",
            body: SearchTagsRequest(query: query, knownTags: knownTags)
        )
        return try await decodeResponse(SearchAIResult.self, from: request)
    }

    private func makeJSONRequest<T: Encodable>(path: String, body: T) throws -> URLRequest {
        let url = baseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func decodeResponse<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw AIServiceError.backendFailed
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw AIServiceError.invalidResponse
        }
    }
}

struct LocalLLMAdapter: AIAdapter {
    func extractMemoMetadata(text: String) async throws -> MemoAIResult {
        throw AIServiceError.notImplemented
    }

    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult {
        throw AIServiceError.notImplemented
    }
}

private struct MemoAnalysisRequest: Encodable {
    var text: String
    var locale: String
}

private struct SearchTagsRequest: Encodable {
    var query: String
    var knownTags: [String]
}
