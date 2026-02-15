import Foundation
import Testing

@testable import App

@Suite
struct StudyResultScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順3,5,6,7
    @Test("ユースケース1: 学習結果を確認する - 基本フロー")
    @MainActor
    func loadResult_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyResultScreenUseCase
        let sessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 不正解1件のセッションが存在する ──
        let wordID = UUID()
        let answer = try TestFactory.answer(wordID: wordID, judgment: .incorrect)
        let session = try TestFactory.session(requestedCount: 1, answers: [answer])
        try await sessionRepository.save(session: session)

        // ── 操作: 成績詳細画面を表示する（手順1） ──
        let effects = await (await useCase.loadResult(sessionID: session.id)).collectAll()

        // ── 検証 ──
        #expect(effects.contains(.showSummary(correctCount: 0, incorrectCount: 1)), "手順5,6: 正解数と不正解数を表示すること")
        #expect(effects.contains(.showAnswers([answer])), "手順7: 正誤詳細一覧を表示すること")
    }

    // 仕様トレース: ユースケース2 手順2
    @Test("ユースケース2: 成績一覧画面へ戻る - 基本フロー")
    @MainActor
    func backToProblemList_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyResultScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 成績一覧へ戻るボタンをタップする（手順1） ──
        let effects = await (await useCase.backToProblemList()).collectAll()

        // ── 検証 ──
        #expect(effects == [.navigateToProblemList], "手順2: 成績一覧画面へ遷移すること")
    }

    // 仕様トレース: ユースケース3 手順3,4
    @Test("ユースケース3: 復習学習を再開する - 基本フロー")
    @MainActor
    func restartReview_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyResultScreenUseCase
        let sessionRepository = app.studySessionRepositoryForTest
        let wordRepository = app.wordRepositoryForTest

        // ── 前提: 復習対象が存在する ──
        let word = try TestFactory.word()
        try await wordRepository.insert(word)

        let answer = try TestFactory.answer(wordID: word.id, judgment: .incorrect)
        let session = try TestFactory.session(requestedCount: 1, answers: [answer])
        try await sessionRepository.save(session: session)

        // ── 操作: 復習するボタンをタップする（手順1） ──
        let effects = await (await useCase.restartReview(sessionID: session.id)).collectAll()

        // ── 検証 ──
        #expect(effects.first == .showLoading, "手順3: 復習学習を開始すること")
        #expect(effects.contains { effect in
            if case .navigateToStudyCard = effect { return true }
            return false
        }, "手順4: 学習カード画面へ遷移すること")
    }
}
