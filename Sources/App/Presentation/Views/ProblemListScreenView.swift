// このファイルは自動生成されています

import SwiftUI

public struct ProblemListScreenView: View, EffectHandlingView {
    @Environment(\.problemListScreenUseCase) private var useCase
    @Environment(AppState.self) public var appState
    @State public var viewState = ProblemListScreenViewState()

    public init() {}

    public var body: some View {
        VStack {
            if viewState.isEmptyStateVisible {
                ContentUnavailableView(
                    "まだ履歴がありません",
                    systemImage: "tray",
                    description: Text("学習を開始するとここに記録されます。")
                )
            } else {
                List(viewState.rows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.title)
                            .font(.headline)
                        Text(row.summary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        handle {
                            await useCase.openHistoryDetail(sessionID: row.sessionID)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay {
            if viewState.isLoading {
                ProgressView()
            }
        }
        .alert(
            "エラー",
            isPresented: Binding(
                get: { viewState.alertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewState.alertMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewState.alertMessage ?? "")
        }
        .task {
            handle { await useCase.loadHistoryList() }
        }
    }
}
