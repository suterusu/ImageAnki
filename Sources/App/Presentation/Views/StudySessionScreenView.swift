import SwiftUI

public struct StudySessionScreenView: View, EffectHandlingView {
    private let sessionID: UUID

    @Environment(\.studySessionScreenUseCase) private var useCase
    @Environment(AppState.self) private var appState

    @State private var viewState = StudySessionScreenViewState()
    @State private var cardOffset: CGSize = .zero

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("進捗 \(viewState.progressText)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                Text("現在の問題")
                    .font(.headline)

                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(height: 340)
                    VStack(spacing: 10) {
                        Text(viewState.currentCardFace == .prompt ? viewState.currentCardPromptText : viewState.currentCardMeaningText)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        Text("画像: \(viewState.currentCardImageName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .offset(cardOffset)
                .rotationEffect(.degrees(cardOffset.width / 20))
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: cardOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            cardOffset = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 90
                            if value.translation.width > threshold {
                                handle { await useCase.submitJudgment(sessionID: sessionID, judgment: .correct) }
                            } else if value.translation.width < -threshold {
                                handle { await useCase.submitJudgment(sessionID: sessionID, judgment: .incorrect) }
                            }
                            cardOffset = .zero
                        }
                )
                .onLongPressGesture {
                    handle { await useCase.toggleCardFace() }
                }

                Text("長押しで意味表示に切り替え")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("右スワイプで正解 / 左スワイプで不正解")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
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
            handle { await useCase.loadSession(sessionID: sessionID) }
        }
        .navigationTitle("学習セッション")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func handle(_ execute: @escaping @MainActor () async -> AsyncStream<StudySessionViewEffect>) {
        Task { @MainActor in
            let stream = await execute()
            for await effect in stream {
                switch effect {
                case .screen(let screenEffect):
                    if case .showMeaningFace = screenEffect, viewState.currentCardFace == .meaning {
                        viewState.apply(.screen(.showPromptFace))
                    } else {
                        viewState.apply(effect)
                    }
                    appState.apply(screenEffect.asAppEffect())
                case .alert:
                    viewState.apply(effect)
                }
            }
        }
    }
}
