import SwiftUI

public struct PerformanceListScreenView: View, EffectHandlingView {
    @Environment(\.performanceListScreenUseCase) private var useCase
    @Environment(AppState.self) private var appState

    @State private var viewState = PerformanceListScreenViewState()

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学習履歴の概要")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if viewState.isEmptyStateVisible {
                ContentUnavailableView("成績データがありません", systemImage: "tray")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewState.summaries) { summary in
                    Button {
                        handle {
                            await useCase.selectPerformance(sessionID: summary.sessionID)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(summary.studiedAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("学年: \(summary.gradeLabel)")
                                .font(.subheadline.weight(.semibold))
                            Text("正解 \(summary.correctCount) / 不正解 \(summary.incorrectCount)")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewState.isLoading {
                ProgressView("読み込み中")
            }
        }
        .bindAlert(alertState: $viewState.alertState) { alertEffect, buttonType in
            handle {
                await useCase.handleAlertResult(alertEffect, buttonType: buttonType)
            }
        }
        .task {
            handle { await useCase.fetchPerformanceList() }
        }
        .navigationTitle("成績一覧")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func handle(_ execute: @escaping @MainActor () async -> AsyncStream<PerformanceListViewEffect>) {
        Task { @MainActor in
            let stream = await execute()
            for await effect in stream {
                viewState.apply(effect)
                if case .screen(let screenEffect) = effect {
                    appState.apply(screenEffect.asAppEffect())
                }
            }
        }
    }
}
