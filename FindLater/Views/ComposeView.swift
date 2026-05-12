import SwiftUI

struct ComposeView: View {
    let store: MemoStore
    @Environment(\.dismiss) private var dismiss

    @State private var rawText = ""
    @State private var tagDraft = ""
    @State private var tags: [String] = []
    @State private var category: MemoCategory = .work
    @FocusState private var focusedField: Field?

    private enum Field {
        case body
        case tag
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $rawText)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(MullTheme.ink)
                    .tint(MullTheme.terracotta)
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .background(alignment: .topLeading) {
                        if rawText.isEmpty {
                            Text("생각나는 걸 아무거나 적어보세요")
                                .font(.system(size: 19))
                                .foregroundStyle(MullTheme.inkDisabled)
                                .padding(.horizontal, 23)
                                .padding(.top, 16)
                        }
                    }
                    .focused($focusedField, equals: .body)
                    .accessibilityIdentifier("memoBodyEditor")

                Text("\(rawText.count)자")
                    .font(.caption2.monospaced())
                    .foregroundStyle(MullTheme.inkDisabled)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("태그")
                            .font(.footnote)
                            .foregroundStyle(MullTheme.inkTertiary)
                            .frame(width: 56, alignment: .leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    TagChip(label: tag, isSelected: true) {
                                        tags.removeAll { $0 == tag }
                                    }
                                }

                                TextField("직접 입력", text: $tagDraft)
                                    .font(.caption.weight(.medium))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .frame(width: 90)
                                    .focused($focusedField, equals: .tag)
                                    .onSubmit(addDraftTag)
                                    .accessibilityIdentifier("tagInput")
                            }
                        }
                        .scrollClipDisabled()
                    }

                    HStack(spacing: 10) {
                        Text("카테고리")
                            .font(.footnote)
                            .foregroundStyle(MullTheme.inkTertiary)
                            .frame(width: 56, alignment: .leading)

                        Picker("카테고리", selection: $category) {
                            ForEach(MemoCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("categoryPicker")
                    }

                    AIBanner(
                        title: "AI 태그 추천 예정",
                        message: "지금은 원문, 수동 태그, 수동 카테고리만 저장합니다."
                    )
                }
                .padding(16)
                .background(MullTheme.paper)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(MullTheme.paperLine)
                        .frame(height: 0.5)
                }
            }
            .background(MullTheme.paper)
            .navigationTitle("빠른 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(MullTheme.terracotta)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        addDraftTag()
                        _ = store.createMemo(rawText: rawText, tags: tags, category: category)
                        dismiss()
                    }
                    .disabled(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? MullTheme.inkDisabled : MullTheme.terracotta)
                    .accessibilityIdentifier("saveMemoButton")
                }
            }
            .onAppear {
                focusedField = .body
            }
        }
    }

    private func addDraftTag() {
        let normalized = Memo.normalizedTags(tagDraft.components(separatedBy: CharacterSet(charactersIn: ", ")))
        for tag in normalized where !tags.contains(where: { $0.lowercased() == tag.lowercased() }) {
            tags.append(tag)
        }
        tagDraft = ""
    }
}
