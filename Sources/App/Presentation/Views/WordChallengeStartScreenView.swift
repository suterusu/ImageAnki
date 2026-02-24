import SwiftUI

public struct WordChallengeStartScreenView: View, EffectHandlingView {
    @Environment(\.wordChallengeStartScreenUseCase) private var useCase
    @Environment(AppState.self) private var appState

    @State private var viewState = WordChallengeStartScreenViewState()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("学年と学習数を選んで開始")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    Text("学年")
                        .font(.subheadline.weight(.semibold))
                    Picker("学年", selection: $viewState.selectedGrade) {
                        Text("中1").tag(SchoolGrade.junior1)
                        Text("中2").tag(SchoolGrade.junior2)
                        Text("中3").tag(SchoolGrade.junior3)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 10) {
                    Text("学習数")
                        .font(.subheadline.weight(.semibold))
                    TextField("20", text: $viewState.inputItemCountText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if viewState.isInputErrorVisible {
                    Text("学習数は1〜100で入力してください。")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let emptyMessage = viewState.emptyStateMessage {
                    Text(emptyMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button {
                    handle {
                        await useCase.startLearning(
                            grade: viewState.selectedGrade,
                            itemCountText: viewState.inputItemCountText
                        )
                    }
                } label: {
                    Text("学習する")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    handle {
                        await useCase.startReview(
                            itemCountText: viewState.inputItemCountText
                        )
                    }
                } label: {
                    Text("復習する")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .bindAlert(alertState: $viewState.alertState) { alertEffect, buttonType in
            handle {
                await useCase.handleAlertResult(alertEffect, buttonType: buttonType)
            }
        }
        .navigationTitle("単語挑戦")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func handle(_ execute: @escaping @MainActor () async -> AsyncStream<WordChallengeStartViewEffect>) {
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
