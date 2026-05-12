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
    let store: MemoStore
    let memoID: Memo.ID
    var onDelete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var isRequestingAI = false
    private let aiService = AIService()

    private var memo: Memo? {
        store.notes.first { $0.id == memoID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let memo {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            header(for: memo)
                            rawTextCard(for: memo)
                            classificationSection(for: memo)
                            AISuggestionPanel(
                                memo: memo,
                                isRequesting: isRequestingAI,
                                onRequest: {
                                    requestAISuggestions(for: memo)
                                },
                                onApply: {
                                    store.acceptAISuggestions(id: memo.id)
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 36)
                    }
                    .background(MullTheme.paper)
                } else {
                    ContentUnavailableView("메모를 찾을 수 없습니다", systemImage: "doc.text")
                        .background(MullTheme.paper)
                }
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

    private func header(for memo: Memo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(memo.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(MullTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(memo.createdAt.memoDateLabel)
                .font(.footnote)
                .foregroundStyle(MullTheme.inkTertiary)
        }
    }

    private func rawTextCard(for memo: Memo) -> some View {
        Text(memo.rawText)
            .font(.system(size: 20, weight: .regular))
            .lineSpacing(5)
            .foregroundStyle(MullTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func classificationSection(for memo: Memo) -> some View {
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
    }

    private func requestAISuggestions(for memo: Memo) {
        guard !isRequestingAI else { return }
        isRequestingAI = true
        store.markMemoAIAnalysisPending(id: memo.id)

        Task {
            do {
                let result = try await aiService.extractMemoMetadata(text: memo.rawText)
                await MainActor.run {
                    store.applyMemoAISuggestions(id: memo.id, result: result)
                    isRequestingAI = false
                }
            } catch {
                await MainActor.run {
                    store.markMemoAIAnalysisFailed(id: memo.id, error: aiErrorMessage(error))
                    isRequestingAI = false
                }
            }
        }
    }

    private func aiErrorMessage(_ error: Error) -> String {
        if let serviceError = error as? AIServiceError {
            switch serviceError {
            case .backendFailed:
                return "backend_unreachable"
            case .invalidResponse:
                return "invalid_response"
            case .notImplemented:
                return "not_implemented"
            }
        }
        return "unknown_error"
    }
}

struct AISuggestionPanel: View {
    let memo: Memo
    let isRequesting: Bool
    var onRequest: () -> Void
    var onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .imageScale(.small)
                Text("AI 태그 추천")
                    .font(.footnote.weight(.semibold))
                Spacer()
                statusText
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(MullTheme.sage)

            switch memo.aiStatus {
            case .none:
                Text("원문을 바탕으로 태그와 카테고리 후보를 만들 수 있습니다. 적용 전까지 수동 분류는 바뀌지 않습니다.")
                    .font(.callout)
                    .foregroundStyle(MullTheme.sage)
            case .pending:
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(MullTheme.sage)
                    Text("추천을 준비하고 있습니다.")
                        .font(.callout)
                        .foregroundStyle(MullTheme.sage)
                }
            case .done:
                suggestionContent
            case .failed:
                Text("추천을 불러오지 못했습니다. 메모와 수동 분류는 그대로 유지됩니다.")
                    .font(.callout)
                    .foregroundStyle(MullTheme.sage)
                if let aiError = memo.aiError {
                    Text(aiError)
                        .font(.caption.monospaced())
                        .foregroundStyle(MullTheme.inkTertiary)
                }
            }

            actions
        }
        .padding(16)
        .background(MullTheme.sageSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var statusText: some View {
        switch memo.aiStatus {
        case .none:
            Text("대기")
        case .pending:
            Text("분석 중")
        case .done:
            Text("추천 완료")
        case .failed:
            Text("실패")
        }
    }

    private var suggestionContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let category = memo.aiSuggestedCategory {
                HStack(spacing: 8) {
                    Text("카테고리")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MullTheme.sage)
                    CategoryChip(category: category)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.55), in: Capsule())
                }
            }

            if !memo.aiSuggestedTags.isEmpty {
                FlowLayout(spacing: 7) {
                    ForEach(memo.aiSuggestedTags, id: \.self) { tag in
                        TagChip(label: tag)
                    }
                }
            }

            if let confidence = memo.aiConfidence {
                Text("confidence \(Int((confidence * 100).rounded()))% · \(memo.aiProvider.rawValue)")
                    .font(.caption.monospaced())
                    .foregroundStyle(MullTheme.inkTertiary)
            }
        }
    }

    @ViewBuilder
    private var actions: some View {
        HStack(spacing: 10) {
            Button {
                onRequest()
            } label: {
                Label(memo.aiStatus == .failed ? "다시 추천" : "추천 받기", systemImage: "wand.and.stars")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(MullTheme.sage)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.45), in: Capsule())
            }
            .buttonStyle(.plain)
            .contentShape(Capsule())
            .disabled(isRequesting || memo.aiStatus == .pending)
            .accessibilityIdentifier("requestAIButton")

            if memo.aiStatus == .done {
                Button {
                    onApply()
                } label: {
                    Label("적용", systemImage: "checkmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(MullTheme.sage, in: Capsule())
                }
                .buttonStyle(.plain)
                .contentShape(Capsule())
                .accessibilityIdentifier("applyAISuggestionsButton")
            }
        }
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
