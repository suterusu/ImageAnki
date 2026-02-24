import SwiftUI

public struct PerformanceDetailScreenView: View, EffectHandlingView {
    private let sessionID: UUID

    @Environment(\.performanceDetailScreenUseCase) private var useCase
    @Environment(AppState.self) private var appState

    @State private var viewState: PerformanceDetailScreenViewState

    public init(sessionID: UUID) {
        self.sessionID = sessionID
        _viewState = State(initialValue: PerformanceDetailScreenViewState(sessionID: sessionID))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    VStack {
                        Text("正解 \(viewState.correctCount)")
                            .font(.headline)
                            .foregroundStyle(Color.green.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack {
                        Text("不正解 \(viewState.incorrectCount)")
                            .font(.headline)
                            .foregroundStyle(Color.red.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("正解一覧")
                        .font(.headline)
                    ForEach(viewState.correctWords, id: \.self) { word in
                        Text("• \(word)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("不正解一覧")
                        .font(.headline)
                    ForEach(viewState.incorrectWords, id: \.self) { word in
                        Text("• \(word)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewState.isLoading {
                ProgressView("読み込み中")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("戻る") {
                    handle {
                        await useCase.backToPerformanceList()
                    }
                }
            }
        }
        .bindAlert(alertState: $viewState.alertState) { alertEffect, buttonType in
            handle {
                await useCase.handleAlertResult(alertEffect, buttonType: buttonType)
            }
        }
        .task {
            handle { await useCase.fetchPerformanceDetail(sessionID: sessionID) }
        }
        .navigationTitle("成績詳細")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handle(_ execute: @escaping @MainActor () async -> AsyncStream<PerformanceDetailViewEffect>) {
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
