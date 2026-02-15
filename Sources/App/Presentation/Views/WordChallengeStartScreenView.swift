// このファイルは自動生成されています

import SwiftUI

public struct WordChallengeStartScreenView: View, EffectHandlingView {
    @Environment(\.wordChallengeStartScreenUseCase) private var useCase
    @Environment(AppState.self) public var appState
    @State public var viewState = WordChallengeStartScreenViewState()

    @State private var customCountText: String = ""

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("単語挑戦を始める")
                    .font(.title)
                    .fontWeight(.bold)

                Text("学年")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(SchoolGrade.allCases, id: \.self) { grade in
                        Button(label(for: grade)) {
                            viewState.selectedGrade = grade
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(viewState.selectedGrade == grade ? .blue : .gray)
                    }
                }

                Text("学習数")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach([10, 20, 30], id: \.self) { count in
                        Button("\(count)") {
                            viewState.selectedStudyCount = count
                            customCountText = ""
                        }
                        .buttonStyle(.bordered)
                        .tint(viewState.selectedStudyCount == count ? .blue : .gray)
                    }
                }

                TextField("任意の学習数", text: $customCountText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                if let inputErrorMessage = viewState.inputErrorMessage {
                    Text(inputErrorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                HStack(spacing: 12) {
                    Button("学習する") {
                        handle {
                            await useCase.startNormalStudy(
                                selectedGrade: viewState.selectedGrade,
                                selectedStudyCount: viewState.selectedStudyCount,
                                inputStudyCount: customCountText
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("復習する") {
                        handle {
                            await useCase.startReviewStudy(
                                selectedStudyCount: viewState.selectedStudyCount,
                                inputStudyCount: customCountText
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
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
            handle { await useCase.loadSelection() }
        }
    }

    private func label(for grade: SchoolGrade) -> String {
        switch grade {
        case .middle1: return "中1"
        case .middle2: return "中2"
        case .middle3: return "中3"
        }
    }
}
