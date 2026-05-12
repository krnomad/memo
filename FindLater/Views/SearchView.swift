import SwiftUI

struct SearchView: View {
    let store: MemoStore
    @State private var query: String

    private let recentSearches = ["Growise", "블루스크린", "공기압", "MVP"]

    init(store: MemoStore, initialQuery: String = "") {
        self.store = store
        _query = State(initialValue: initialQuery)
    }

    private var results: [Memo] {
        store.search(query)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SearchBar(
                        text: $query,
                        placeholder: "메모 · 태그 · 카테고리 검색",
                        identifier: "searchField"
                    )

                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("최근 검색")
                            .searchSectionHeading()

                        VStack(spacing: 0) {
                            ForEach(recentSearches, id: \.self) { term in
                                Button {
                                    query = term
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
                                }
                            }
                        }

                        AIBanner(
                            title: "자연어 검색 예정",
                            message: "지금은 원문, 태그, 카테고리를 직접 검색합니다."
                        )
                    } else {
                        Text("\(results.count)개의 결과")
                            .font(.footnote)
                            .foregroundStyle(MullTheme.inkTertiary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 10) {
                            ForEach(results) { memo in
                                NoteCard(memo: memo)
                            }
                        }

                        AIBanner(
                            title: "AI 검색 예정",
                            message: "“견적 다시 봐야 하는 일”처럼 묻는 검색은 아직 동작하지 않습니다."
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
            .background(MullTheme.paper)
            .navigationTitle("검색")
        }
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
