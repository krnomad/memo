import SwiftUI

enum AppTab: Hashable {
    case home
    case browse
    case search
}

enum ActiveSheet: Identifiable {
    case compose

    var id: String {
        switch self {
        case .compose:
            return "compose"
        }
    }
}

struct ContentView: View {
    let store: MemoStore
    let launchConfiguration: LaunchConfiguration
    @State private var selectedTab: AppTab
    @State private var activeSheet: ActiveSheet?
    private let tabOrder: [AppTab] = [.home, .browse, .search]

    init(store: MemoStore, launchConfiguration: LaunchConfiguration = LaunchConfiguration()) {
        self.store = store
        self.launchConfiguration = launchConfiguration
        _selectedTab = State(initialValue: launchConfiguration.initialTab)
        _activeSheet = State(initialValue: launchConfiguration.showCompose ? .compose : nil)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(store: store, activeSheet: $activeSheet)
                .tabItem {
                    Label("최근", systemImage: "doc.text")
                }
                .tag(AppTab.home)
                .accessibilityIdentifier("homeTab")

            BrowseView(
                store: store,
                activeSheet: $activeSheet,
                initialFilter: launchConfiguration.initialBrowseFilter
            )
                .tabItem {
                    Label("탐색", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.browse)
                .accessibilityIdentifier("browseTab")

            SearchView(
                store: store,
                activeSheet: $activeSheet,
                initialQuery: launchConfiguration.initialSearchQuery
            )
                .tabItem {
                    Label("검색", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)
                .accessibilityIdentifier("searchTab")
        }
        .tint(MullTheme.terracotta)
        .simultaneousGesture(
            DragGesture(minimumDistance: 42, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    guard abs(horizontal) > 55, abs(horizontal) > abs(vertical) * 1.35 else { return }
                    moveTab(by: horizontal < 0 ? 1 : -1)
                }
        )
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .compose:
                ComposeView(store: store)
            }
        }
        .onAppear {
            if launchConfiguration.showCompose {
                activeSheet = .compose
            }
        }
    }

    private func moveTab(by offset: Int) {
        guard let currentIndex = tabOrder.firstIndex(of: selectedTab) else { return }
        let nextIndex = min(max(currentIndex + offset, tabOrder.startIndex), tabOrder.index(before: tabOrder.endIndex))
        selectedTab = tabOrder[nextIndex]
    }
}
