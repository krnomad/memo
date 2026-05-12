import SwiftUI

struct NoteCard: View {
    let memo: Memo

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
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("noteCard-\(memo.id.uuidString)")
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

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MullTheme.inkTertiary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(identifier)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(MullTheme.paperGrouped, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
