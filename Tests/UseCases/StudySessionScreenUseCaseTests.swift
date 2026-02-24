import Foundation
import ImageAnki
import Testing

struct StudySessionScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順2,3,4,5,6
    @Test("ユースケース1: 学習セッションを開始して問題カードを表示する - 基本フロー")
    @MainActor
    func loadSession_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studySessionScreenUseCase
        let wordCardRepository = app.wordCardRepositoryForTest
        let studySessionRepository = app.studySessionRepositoryForTest

        // ── 前提: セッションとカードが存在する ──
        let cardID = UUID()
        try await wordCardRepository.insert(.test(id: cardID, grade: .junior1, promptText: "apple", meaningText: "りんご", imagePNGName: "apple.png"))
        let session = StudySession.test(targetCount: 1, cardIDs: [cardID])
        try await studySessionRepository.insert(session)

        // ── 操作: 画面表示時の読み込み（手順2） ──
        let effects = await (await useCase.loadSession(sessionID: session.id)).collectAll()

        // ── 検証 ──
        #expect(effects.first == .screen(.showLoading), "手順2: showLoadingを返すこと")
        #expect(effects.contains(where: {
            if case .screen(.updateCard) = $0 { return true }
            return false
        }), "手順5: 現在カード画像を表示すること")
    }

    // 仕様トレース: ユースケース2 分岐フローA 手順3-A,4-A,5-A
    @Test("ユースケース2: 現在カードの判定結果を入力する - 分岐フローA: 最終カードを判定")
    @MainActor
    func submitJudgment_finishSession() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studySessionScreenUseCase
        let wordCardRepository = app.wordCardRepositoryForTest
        let studySessionRepository = app.studySessionRepositoryForTest

        // ── 前提: カード1枚だけのセッション ──
        let cardID = UUID()
        try await wordCardRepository.insert(.test(id: cardID, grade: .junior1, promptText: "apple", meaningText: "りんご", imagePNGName: "apple.png"))
        let session = StudySession.test(targetCount: 1, cardIDs: [cardID])
        try await studySessionRepository.insert(session)

        // ── 操作: 判定を入力する（手順2） ──
        let effects = await (await useCase.submitJudgment(sessionID: session.id, judgment: .correct)).collectAll()

        // ── 検証 ──
        #expect(effects.contains(.screen(.navigateToPerformanceList)), "手順5-A: 成績一覧画面へ遷移すること")
    }

    // 仕様トレース: ユースケース3 手順1,2
    @Test("ユースケース3: カードの表示内容を切り替える - 基本フロー")
    @MainActor
    func toggleCardFace_success() async {
        let app = AppDependencies.make(for: .test)
        let useCase = app.studySessionScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 表示切り替えを要求する（手順1） ──
        let effects = await (await useCase.toggleCardFace()).collectAll()

        // ── 検証 ──
        #expect(effects == [.screen(.showMeaningFace)], "手順2: 意味表示へ切り替えること")
    }
}
