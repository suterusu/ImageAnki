// このファイルは自動生成されています

import SwiftUI

public struct StudyCardScreenView: View, EffectHandlingView {
    @Environment(\.studyCardScreenUseCase) private var useCase
    @Environment(AppState.self) public var appState
    @State public var viewState = StudyCardScreenViewState()

    private let sessionID: UUID

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("進捗 \(viewState.currentIndex) / \(viewState.totalCount)")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))

                Text(cardText)
                    .font(.title2)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 320)
            .onLongPressGesture {
                handle {
                    await useCase.toggleCardFace(isAnswerSide: viewState.isAnswerSide)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        guard let wordID = viewState.currentCard?.id else {
                            return
                        }
                        if value.translation.width > 0 {
                            handle {
                                await useCase.judgeCorrect(sessionID: sessionID, wordID: wordID)
                            }
                        } else {
                            handle {
                                await useCase.judgeIncorrect(sessionID: sessionID, wordID: wordID)
                            }
                        }
                    }
            )

            Text("長押しで問題/答えを切替、右スワイプで正解、左スワイプで不正解")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
            handle { await useCase.loadCards(sessionID: sessionID) }
        }
    }

    private var cardText: String {
        guard let currentCard = viewState.currentCard else {
            return "出題カードを読み込み中..."
        }
        return viewState.isAnswerSide ? currentCard.answerImageName : currentCard.problemImageName
    }
}
