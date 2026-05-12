import SwiftUI

struct HomeView: View {
    let store: MemoStore
    @Binding var activeSheet: ActiveSheet?
    @State private var selectedMemo: Memo?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(store.recentGroups, id: \.title) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.title)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(MullTheme.inkTertiary)
                                    .padding(.horizontal, 4)

                                ForEach(group.notes) { memo in
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
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 110)
                }
                .background(MullTheme.paper)
                .scrollDismissesKeyboard(.immediately)

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
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedMemo) { memo in
                MemoDetailView(
                    memo: memo,
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
