import SwiftUI

enum BrowseFilter: Equatable {
    case category(MemoCategory)
    case tag(String)

    var title: String {
        switch self {
        case .category(let category):
            return category.rawValue
        case .tag(let tag):
            return "#\(tag)"
        }
    }
}

struct BrowseView: View {
    let store: MemoStore
    @Binding var activeSheet: ActiveSheet?
    @State private var filter: BrowseFilter
    @State private var selectedMemo: Memo?

    init(store: MemoStore, activeSheet: Binding<ActiveSheet?>, initialFilter: BrowseFilter = .category(.work)) {
        self.store = store
        _activeSheet = activeSheet
        _filter = State(initialValue: initialFilter)
    }

    private var filteredNotes: [Memo] {
        switch filter {
        case .category(let category):
            store.notes(for: category)
        case .tag(let tag):
            store.notes(tagged: tag)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("카테고리")
                            .sectionHeading()

                        VStack(spacing: 0) {
                            ForEach(MemoCategory.allCases) { category in
                                Button {
                                    filter = .category(category)
                                } label: {
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                                            .fill(category.tint)
                                            .frame(width: 10, height: 10)
                                        Text(category.rawValue)
                                            .foregroundStyle(MullTheme.ink)
                                        Spacer()
                                        Text("\(store.notes(for: category).count)")
                                            .foregroundStyle(MullTheme.inkTertiary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                    .background(filter == .category(category) ? MullTheme.terracottaSoft : .clear)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("category-\(category.rawValue)")

                                if category != MemoCategory.allCases.last {
                                    Divider().padding(.leading, 38)
                                }
                            }
                        }
                        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Text("태그")
                            .sectionHeading()

                        FlowLayout(spacing: 7) {
                            ForEach(store.popularTags, id: \.tag) { item in
                                TagChip(label: item.tag, isSelected: filter == .tag(item.tag)) {
                                    filter = .tag(item.tag)
                                }
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Text("\(filter.title) 메모")
                            .sectionHeading()

                        VStack(spacing: 10) {
                            ForEach(filteredNotes) { memo in
                                NoteCard(
                                    memo: memo,
                                    onOpen: {
                                        selectedMemo = memo
                                    },
                                    onDelete: {
                                        store.deleteMemo(id: memo.id)
                                    }
                                )
                            }
                        }

                        AIBanner(
                            title: "AI 자동 분류 예정",
                            message: "비슷한 메모끼리 자동으로 묶고, 카테고리를 추천하는 자리입니다."
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
                .background(MullTheme.paper)

                Button {
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
                .accessibilityIdentifier("browseComposeButton")
                .padding(.trailing, 18)
                .padding(.bottom, 20)
            }
            .navigationTitle("탐색")
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
        }
    }
}

private extension Text {
    func sectionHeading() -> some View {
        self
            .font(.footnote.weight(.semibold))
            .foregroundStyle(MullTheme.inkTertiary)
            .padding(.horizontal, 4)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
