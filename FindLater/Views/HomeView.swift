import SwiftUI

struct HomeView: View {
    let store: MemoStore
    @Binding var activeSheet: ActiveSheet?
    @Binding var selectedTab: AppTab
    @State private var homeSearchText = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        SearchBar(
                            text: $homeSearchText,
                            placeholder: "검색",
                            identifier: "homeSearchField"
                        )
                        .onSubmit {
                            selectedTab = .search
                        }

                        ForEach(store.recentGroups, id: \.title) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.title)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(MullTheme.inkTertiary)
                                    .padding(.horizontal, 4)

                                ForEach(group.notes) { memo in
                                    NoteCard(memo: memo)
                                }
                            }
                        }
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
                .accessibilityIdentifier("composeButton")
                .padding(.trailing, 18)
                .padding(.bottom, 20)
            }
            .navigationTitle("흘려쓰기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Find Later")
                        .font(.custom("Newsreader", size: 17).italic())
                        .foregroundStyle(MullTheme.terracotta)
                }
            }
        }
    }
}
