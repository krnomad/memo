import Foundation

enum AppAIProvider: String, Codable, Sendable {
    case mock
    case backendCodex = "backend-codex"
    case localLLM = "local-llm"
}

struct AIConfiguration: Equatable, Sendable {
    static let defaultBackendBaseURL = URL(string: "http://100.72.125.75:8989")!

    var provider: AppAIProvider
    var backendBaseURL: URL
    var diagnosticsEnabled: Bool

    static var current: AIConfiguration {
        AIConfiguration(arguments: ProcessInfo.processInfo.arguments)
    }

    init(
        provider: AppAIProvider = .mock,
        backendBaseURL: URL = AIConfiguration.defaultBackendBaseURL,
        diagnosticsEnabled: Bool = false
    ) {
        self.provider = provider
        self.backendBaseURL = backendBaseURL
        self.diagnosticsEnabled = diagnosticsEnabled
    }

    init(arguments: [String]) {
        let providerValue = Self.value(after: "--ai-provider", in: arguments)
        switch providerValue {
        case "backend", "backend-codex", "codex-cli":
            provider = .backendCodex
        case "local", "local-llm":
            provider = .localLLM
        default:
            provider = .mock
        }

        if let urlValue = Self.value(after: "--ai-backend-url", in: arguments),
           let url = URL(string: urlValue) {
            backendBaseURL = url
        } else {
            backendBaseURL = Self.defaultBackendBaseURL
        }

        diagnosticsEnabled = arguments.contains("--ai-diagnostics")
    }

    func makeAdapter() -> AIAdapter {
        switch provider {
        case .mock:
            return MockAIAdapter()
        case .backendCodex:
            return BackendCodexAdapter(baseURL: backendBaseURL)
        case .localLLM:
            return LocalLLMAdapter()
        }
    }

    var diagnosticsSummary: String {
        "\(provider.rawValue) · \(backendBaseURL.absoluteString)"
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }
}
