import Foundation
import ImageAnki
import Testing

struct WordChallengeStartScreenUseCaseTests {
    // 仕様トレース: ユースケース2 手順2,3,4,5,6
    @Test("ユースケース2: 学習モードで学習を開始する - 基本フロー")
    @MainActor
    func startLearning_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.wordChallengeStartScreenUseCase
        let repository = app.wordCardRepositoryForTest

        // ── 前提: 学習対象カードが1件ある ──
        try await repository.insert(.test(grade: .junior1, promptText: "apple", meaningText: "りんご", imagePNGName: "apple.png"))

        // ── 操作: 学習開始を要求する（手順2） ──
        let effects = await (await useCase.startLearning(grade: .junior1, itemCountText: "1")).collectAll()

        // ── 検証 ──
        #expect(effects.contains(.screen(.showLoading)), "手順2: showLoadingを返すこと")
        #expect(effects.contains(where: {
            if case .screen(.navigateToStudySession) = $0 { return true }
            return false
        }), "手順6: 学習セッション画面へ遷移すること")
    }

    // 仕様トレース: ユースケース1 分岐フローA 手順5-A,6-A
    @Test("ユースケース1: 学習条件を入力する - 分岐フローA: 学習数未入力")
    @MainActor
    func startLearning_invalidCount() async {
        let app = AppDependencies.make(for: .test)
        let useCase = app.wordChallengeStartScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 学習開始を要求する（手順5-A） ──
        let effects = await (await useCase.startLearning(grade: .junior1, itemCountText: "")).collectAll()

        // ── 検証 ──
        #expect(effects.contains(.screen(.showInputError)), "手順6-A: 入力エラー表示を行うこと")
        #expect(effects.contains(.alert(.showError(.invalidStudyItemCount))), "手順7-A: エラーアラートを表示すること")
    }
}
