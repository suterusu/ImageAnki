import Foundation
import Testing

@testable import App

@Suite
struct WordChallengeStartScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順2,3
    @Test("ユースケース1: 学習条件を選択する - 基本フロー")
    @MainActor
    func loadSelection_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.wordChallengeStartScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 単語挑戦画面を表示する（手順1） ──
        let effects = await (await useCase.loadSelection()).collectAll()

        // ── 検証 ──
        #expect(effects.contains(.showSelectedGrade(.middle1)), "手順2: 学年選択肢が表示されること")
        #expect(effects.contains(.showSelectedStudyCount(10)), "手順3: 学習数選択肢が表示されること")
    }

    // 仕様トレース: ユースケース2 例外フローA 手順2-A,3-A
    @Test("ユースケース2: 通常学習を開始する - 例外フローA")
    @MainActor
    func startNormalStudy_withoutGrade_showsInputError() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.wordChallengeStartScreenUseCase

        // ── 前提: 学年未選択 ──

        // ── 操作: 学習するボタンをタップする（手順1） ──
        let effects = await (await useCase.startNormalStudy(
            selectedGrade: nil,
            selectedStudyCount: 10,
            inputStudyCount: ""
        )).collectAll()

        // ── 検証 ──
        #expect(effects == [.showInputError(.gradeNotSelected)], "手順3-A: 入力エラー表示を行うこと")
    }

    // 仕様トレース: ユースケース3 基本フロー 手順3,4,6
    @Test("ユースケース3: 復習学習を開始する - 基本フロー")
    @MainActor
    func startReviewStudy_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.wordChallengeStartScreenUseCase
        let sessionRepository = app.studySessionRepositoryForTest
        let wordRepository = app.wordRepositoryForTest

        // ── 前提: 復習対象が存在する ──
        let word = try TestFactory.word()
        try await wordRepository.insert(word)

        var oldSession = try TestFactory.session(requestedCount: 1)
        let incorrect = try TestFactory.answer(wordID: word.id, judgment: .incorrect)
        oldSession.recordAnswer(answer: incorrect)
        oldSession.finalize()
        try await sessionRepository.save(session: oldSession)

        // ── 操作: 復習するボタンをタップする（手順1） ──
        let effects = await (await useCase.startReviewStudy(
            selectedStudyCount: 1,
            inputStudyCount: ""
        )).collectAll()

        // ── 検証 ──
        #expect(effects.first == .showLoading, "手順3: ローディングを表示すること")
        #expect(effects.contains { effect in
            if case .navigateToStudyCard = effect { return true }
            return false
        }, "手順6: 学習カード画面へ遷移すること")
    }
}
