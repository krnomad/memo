import SwiftUI

struct SearchView: View {
    let store: MemoStore
    @Binding var activeSheet: ActiveSheet?
    @State private var query: String
    @State private var selectedMemo: Memo?
    @State private var aiSearchResult: SearchAIResult?
    @State private var isAISearching = false
    @State private var aiSearchFailed = false
    @FocusState private var searchFocused: Bool

    private let recentSearches = ["Growise", "블루스크린", "공기압", "MVP"]
    private let aiService = AIService()
    private let searchService = NoteSearchService()

    init(store: MemoStore, activeSheet: Binding<ActiveSheet?>, initialQuery: String = "") {
        self.store = store
        _activeSheet = activeSheet
        _query = State(initialValue: initialQuery)
    }

    private var results: [Memo] {
        searchService.search(notes: store.notes, query: query, aiResult: aiSearchResult)
    }

    private var knownTags: [String] {
        Memo.normalizedTags(store.notes.flatMap(\.tags))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SearchBar(
                            text: $query,
                            placeholder: "메모 · 태그 · 카테고리 검색",
                            identifier: "searchField",
                            focus: $searchFocused
                        )

                        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("최근 검색")
                                .searchSectionHeading()

                            VStack(spacing: 0) {
                                ForEach(recentSearches, id: \.self) { term in
                                    Button {
                                        query = term
                                        searchFocused = false
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "clock")
                                                .foregroundStyle(MullTheme.inkTertiary)
                                            Text(term)
                                                .foregroundStyle(MullTheme.ink)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("recentSearch-\(term)")

                                    if term != recentSearches.last {
                                        Divider().padding(.leading, 40)
                                    }
                                }
                            }
                            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                            Text("인기 태그")
                                .searchSectionHeading()

                            FlowLayout(spacing: 7) {
                                ForEach(store.popularTags.prefix(8), id: \.tag) { item in
                                    TagChip(label: item.tag) {
                                        query = item.tag
                                        searchFocused = false
                                    }
                                }
                            }

                            AIBanner(
                                title: "AI 검색 준비됨",
                                message: "자연어 검색어를 태그 후보로 바꾸고, 실패하면 일반 검색으로 돌아갑니다."
                            )
                        } else {
                            AISearchStatusView(
                                isSearching: isAISearching,
                                failed: aiSearchFailed,
                                result: aiSearchResult
                            )

                            Text("\(results.count)개의 결과")
                                .font(.footnote)
                                .foregroundStyle(MullTheme.inkTertiary)
                                .padding(.horizontal, 4)

                            VStack(spacing: 10) {
                                ForEach(results) { memo in
                                    NoteCard(
                                        memo: memo,
                                        onOpen: {
                                            searchFocused = false
                                            selectedMemo = memo
                                        },
                                        onDelete: {
                                            store.deleteMemo(id: memo.id)
                                        }
                                    )
                                }
                            }

                            if aiSearchFailed {
                                AIBanner(
                                    title: "AI 검색을 사용할 수 없습니다",
                                    message: "현재는 원문, 제목, 태그, 카테고리 기반 검색 결과를 보여줍니다."
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 110)
                }
                .background(MullTheme.paper)
                .scrollDismissesKeyboard(.immediately)

                if searchFocused {
                    Color.clear
                        .contentShape(Rectangle())
                        .padding(.top, 220)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .onTapGesture {
                            searchFocused = false
                        }
                        .accessibilityHidden(true)
                }

                Button {
                    searchFocused = false
                    activeSheet = .compose
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(MullTheme.terracotta, in: Circle())
                        .shadow(color: MullTheme.ink.opacity(0.18), radius: 20, x: 0, y: 10)
                }
                .accessibilityLabel("새 메모")
                .accessibilityIdentifier("searchComposeButton")
                .padding(.trailing, 18)
                .padding(.bottom, 20)
            }
            .navigationTitle("검색")
            .sheet(item: $selectedMemo) { memo in
                MemoDetailView(
                    store: store,
                    memoID: memo.id,
                    onDelete: {
                        store.deleteMemo(id: memo.id)
                        selectedMemo = nil
                    }
                )
                .presentationDetents([.large])
            }
            .task(id: query) {
                await refreshAISearch(for: query)
            }
        }
    }

    @MainActor
    private func resetAISearch() {
        aiSearchResult = nil
        isAISearching = false
        aiSearchFailed = false
    }

    private func refreshAISearch(for query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            resetAISearch()
            return
        }

        await MainActor.run {
            isAISearching = true
            aiSearchFailed = false
        }

        do {
            try await Task.sleep(for: .milliseconds(220))
            let result = try await aiService.extractSearchTags(query: trimmed, knownTags: knownTags)
            await MainActor.run {
                if self.query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    aiSearchResult = result
                    isAISearching = false
                    aiSearchFailed = false
                }
            }
        } catch is CancellationError {
            return
        } catch {
            await MainActor.run {
                if self.query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    aiSearchResult = nil
                    isAISearching = false
                    aiSearchFailed = true
                }
            }
        }
    }
}

private struct AISearchStatusView: View {
    let isSearching: Bool
    let failed: Bool
    let result: SearchAIResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: "sparkle.magnifyingglass")
                    .imageScale(.small)
                Text(title)
                    .font(.caption.weight(.semibold))
                Spacer()
                if isSearching {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(MullTheme.sage)
                }
            }
            .foregroundStyle(MullTheme.sage)

            if let result, !result.matchedTags.isEmpty || !result.queryTags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(result.matchedTags.prefix(6), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MullTheme.sage)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.45), in: Capsule())
                    }

                    ForEach(result.categoryHints.prefix(2), id: \.self) { category in
                        Text(category.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MullTheme.sage)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.45), in: Capsule())
                    }
                }
            } else {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(MullTheme.sage)
            }
        }
        .padding(14)
        .background(MullTheme.sageSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("aiSearchStatus")
    }

    private var title: String {
        if failed { return "일반 검색으로 표시" }
        if isSearching { return "AI 검색 분석 중" }
        return "AI 검색 보조"
    }

    private var message: String {
        failed ? "AI 태그 추출에 실패했습니다." : "검색어를 태그 후보로 바꾸고 있습니다."
    }
}

private extension Text {
    func searchSectionHeading() -> some View {
        self
            .font(.footnote.weight(.semibold))
            .foregroundStyle(MullTheme.inkTertiary)
            .padding(.horizontal, 4)
    }
}
