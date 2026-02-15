import Foundation
import Testing

@testable import App

@Suite
struct StudyCardScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順3,5,6
    @Test("ユースケース1: 出題カードを確認する - 基本フロー")
    @MainActor
    func loadCards_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyCardScreenUseCase
        let wordRepository = app.wordRepositoryForTest
        let sessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 出題対象が1件存在する ──
        let word = try TestFactory.word()
        try await wordRepository.insert(word)
        let session = try TestFactory.session(requestedCount: 1)
        try await sessionRepository.save(session: session)

        // ── 操作: 学習カード画面を表示する（手順1） ──
        let effects = await (await useCase.loadCards(sessionID: session.id)).collectAll()

        // ── 検証 ──
        #expect(effects.first == .showLoading, "手順2: ローディング状態を表示すること")
        #expect(effects.contains(.showCard(word)), "手順5: 出題カードを表示すること")
    }

    // 仕様トレース: ユースケース2 分岐フローA 手順2-A,3-A
    @Test("ユースケース2: 正解として判定する - 分岐フローA")
    @MainActor
    func judgeCorrect_lastCard_navigatesResult() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyCardScreenUseCase
        let wordRepository = app.wordRepositoryForTest
        let sessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 1問だけの学習セッション ──
        let word = try TestFactory.word()
        try await wordRepository.insert(word)
        let session = try TestFactory.session(requestedCount: 1)
        try await sessionRepository.save(session: session)

        // ── 操作: 出題カードを右スワイプする（手順1） ──
        let effects = await (await useCase.judgeCorrect(sessionID: session.id, wordID: word.id)).collectAll()

        // ── 検証 ──
        #expect(effects.contains { effect in
            if case .navigateToStudyResult(session.id) = effect { return true }
            return false
        }, "手順3-A: 成績詳細画面へ遷移すること")
    }

    // 仕様トレース: ユースケース3 基本フロー 手順2,3
    @Test("ユースケース3: 不正解として判定する - 基本フロー")
    @MainActor
    func judgeIncorrect_showsNextCard() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyCardScreenUseCase
        let wordRepository = app.wordRepositoryForTest
        let sessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 出題対象が2件存在する ──
        let firstWord = try TestFactory.word(id: UUID(), problemImageName: "q1", answerImageName: "a1")
        let secondWord = try TestFactory.word(id: UUID(), problemImageName: "q2", answerImageName: "a2")
        try await wordRepository.insert(firstWord)
        try await wordRepository.insert(secondWord)
        let session = try TestFactory.session(requestedCount: 2)
        try await sessionRepository.save(session: session)

        // ── 操作: 出題カードを左スワイプする（手順1） ──
        let effects = await (await useCase.judgeIncorrect(sessionID: session.id, wordID: firstWord.id)).collectAll()

        // ── 検証 ──
        #expect(effects.contains { effect in
            if case .showCard = effect { return true }
            return false
        }, "手順3: 次の出題カードを表示すること")
    }

    // 仕様トレース: ユースケース4 手順2
    @Test("ユースケース4: 問題面と答え面を切り替える - 基本フロー")
    @MainActor
    func toggleCardFace_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studyCardScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 出題カードを長押しする（手順1） ──
        let effects = await (await useCase.toggleCardFace(isAnswerSide: false)).collectAll()

        // ── 検証 ──
        #expect(effects == [.setCardFace(isAnswerSide: true)], "手順2: カード表示面を切り替えること")
    }
}
