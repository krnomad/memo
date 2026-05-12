import SwiftUI

@main
struct FindLaterApp: App {
    @State private var store = MemoStore()
    private let launchConfiguration = LaunchConfiguration.current
    private let aiConfiguration = AIConfiguration.current

    var body: some Scene {
        WindowGroup {
            ContentView(
                store: store,
                launchConfiguration: launchConfiguration,
                aiConfiguration: aiConfiguration
            )
                .background(MullTheme.paper)
                .onAppear {
                    if launchConfiguration.resetStore {
                        store.resetForUITesting()
                    }
                    if launchConfiguration.seedSmokeMemo {
                        store.createMemo(
                            rawText: "회의 끝나고 민지한테 데모 링크 보내기",
                            tags: ["데모", "민지", "링크"],
                            category: .work
                        )
                    }
                }
        }
    }
}

struct LaunchConfiguration {
    var resetStore = false
    var seedSmokeMemo = false
    var showCompose = false
    var initialTab: AppTab = .home
    var initialSearchQuery = ""
    var initialBrowseFilter: BrowseFilter = .category(.work)

    static var current: LaunchConfiguration {
        var config = LaunchConfiguration()
        let arguments = ProcessInfo.processInfo.arguments

        config.resetStore = arguments.contains("--reset-store")
        config.seedSmokeMemo = arguments.contains("--seed-smoke-memo")
        config.showCompose = arguments.contains("--show-compose")

        if let tab = value(after: "--start-tab", in: arguments) {
            switch tab {
            case "browse":
                config.initialTab = .browse
            case "search":
                config.initialTab = .search
            default:
                config.initialTab = .home
            }
        }

        if let query = value(after: "--search", in: arguments) {
            config.initialSearchQuery = query
            config.initialTab = .search
        }

        if let category = value(after: "--browse-category", in: arguments),
           let memoCategory = MemoCategory(rawValue: category) {
            config.initialBrowseFilter = .category(memoCategory)
            config.initialTab = .browse
        }

        if let tag = value(after: "--browse-tag", in: arguments) {
            config.initialBrowseFilter = .tag(tag)
            config.initialTab = .browse
        }

        return config
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }
}
