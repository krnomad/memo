import SwiftUI

struct NoteCard: View {
    let memo: Memo
    var onOpen: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(memo.title)
                    .font(.headline)
                    .foregroundStyle(MullTheme.ink)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(memo.createdAt.memoDateLabel)
                    .font(.caption)
                    .foregroundStyle(MullTheme.inkTertiary)
            }

            Text(memo.rawText)
                .font(.subheadline)
                .foregroundStyle(MullTheme.inkTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    CategoryChip(category: memo.category)
                    ForEach(memo.tags, id: \.self) { tag in
                        TagChip(label: tag, isSelected: false)
                    }
                }
            }
            .scrollClipDisabled()
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: MullTheme.ink.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            if memo.aiStatus == .pending {
                Circle()
                    .fill(MullTheme.sage)
                    .frame(width: 6, height: 6)
                    .padding(14)
                    .accessibilityLabel("AI 분석 대기 중")
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            onOpen?()
        }
        .contextMenu {
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(onOpen == nil ? [] : .isButton)
        .accessibilityIdentifier("noteCard-\(memo.id.uuidString)")
    }
}

struct MemoDetailView: View {
    let memo: Memo
    var onDelete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(memo.title)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(MullTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(memo.createdAt.memoDateLabel)
                            .font(.footnote)
                            .foregroundStyle(MullTheme.inkTertiary)
                    }

                    Text(memo.rawText)
                        .font(.system(size: 20, weight: .regular))
                        .lineSpacing(5)
                        .foregroundStyle(MullTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("분류")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(MullTheme.inkTertiary)

                        FlowLayout(spacing: 7) {
                            CategoryChip(category: memo.category)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(MullTheme.paperGrouped, in: Capsule())

                            ForEach(memo.tags, id: \.self) { tag in
                                TagChip(label: tag)
                            }
                        }
                    }

                    if memo.aiStatus == .pending {
                        AIBanner(
                            title: "AI 분석 대기 중",
                            message: "나중에 자동 태그와 카테고리 추천을 붙일 자리입니다."
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 36)
            }
            .background(MullTheme.paper)
            .navigationTitle("메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundStyle(MullTheme.terracotta)
                }

                if let onDelete {
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("삭제")
                    }
                }
            }
        }
        .accessibilityIdentifier("memoDetail")
    }
}

struct TagChip: View {
    let label: String
    var isSelected: Bool = false
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Text(label.hasPrefix("#") ? label : "#\(label)")
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? Color(hex: 0x8E4A28) : MullTheme.inkSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? MullTheme.terracottaSoft : MullTheme.paperGrouped)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityIdentifier("tag-\(label)")
    }
}

struct CategoryChip: View {
    let category: MemoCategory

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(category.tint)
                .frame(width: 7, height: 7)

            Text(category.rawValue)
                .font(.caption.weight(.medium))
                .foregroundStyle(MullTheme.inkSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct AIBanner: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: "sparkle")
                    .imageScale(.small)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(MullTheme.sage)

            Text(message)
                .font(.callout)
                .italic()
                .foregroundStyle(MullTheme.sage)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MullTheme.sageSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("aiPlaceholderBanner")
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let identifier: String
    var focus: FocusState<Bool>.Binding? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MullTheme.inkTertiary)
            textField
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(MullTheme.paperGrouped, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private var textField: some View {
        if let focus {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused(focus)
                .accessibilityIdentifier(identifier)
        } else {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(identifier)
        }
    }
}
