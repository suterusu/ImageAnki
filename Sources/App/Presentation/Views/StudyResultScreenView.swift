// このファイルは自動生成されています

import SwiftUI

public struct StudyResultScreenView: View, EffectHandlingView {
    @Environment(\.studyResultScreenUseCase) private var useCase
    @Environment(AppState.self) public var appState
    @State public var viewState = StudyResultScreenViewState()

    private let sessionID: UUID

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                scoreCard(title: "正解", value: viewState.correctCount, color: .green)
                scoreCard(title: "不正解", value: viewState.incorrectCount, color: .red)
            }

            List(viewState.answers, id: \.id) { answer in
                HStack {
                    Text("単語ID: \(answer.wordID.uuidString.prefix(8))")
                    Spacer()
                    Text(answer.judgment == .correct ? "正解" : "不正解")
                        .foregroundStyle(answer.judgment == .correct ? .green : .red)
                }
            }
            .listStyle(.plain)

            HStack(spacing: 12) {
                Button("成績一覧へ戻る") {
                    handle { await useCase.backToProblemList() }
                }
                .buttonStyle(.bordered)

                Button("復習する") {
                    handle { await useCase.restartReview(sessionID: sessionID) }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
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
            handle { await useCase.loadResult(sessionID: sessionID) }
        }
    }

    @ViewBuilder
    private func scoreCard(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
            Text("\(value)")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}
