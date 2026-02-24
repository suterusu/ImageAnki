import Foundation
import ImageAnki
import Testing

struct PerformanceDetailScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順2,3,4,5,6,7
    @Test("ユースケース1: 学習成績詳細を確認する - 基本フロー")
    @MainActor
    func fetchPerformanceDetail_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.performanceDetailScreenUseCase
        let wordCardRepository = app.wordCardRepositoryForTest
        let studySessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 成績詳細対象セッションと回答カードが存在する ──
        let cardID = UUID()
        try await wordCardRepository.insert(.test(id: cardID, grade: .junior1, promptText: "apple", meaningText: "りんご", imagePNGName: "apple.png"))
        var session = StudySession.test(targetCount: 1, cardIDs: [cardID])
        _ = session.recordAnswer(cardID: cardID, judgment: .correct, answeredAt: Date())
        try await studySessionRepository.insert(session)

        // ── 操作: 成績詳細を読み込む（手順2） ──
        let effects = await (await useCase.fetchPerformanceDetail(sessionID: session.id)).collectAll()

        // ── 検証 ──
        #expect(effects.first == .screen(.showLoading), "手順2: showLoadingを返すこと")
        #expect(effects.contains(where: {
            if case .screen(.updateDetail) = $0 { return true }
            return false
        }), "手順5-7: 成績詳細情報を表示すること")
    }

    // 仕様トレース: ユースケース2 手順1,2
    @Test("ユースケース2: 成績一覧へ戻る - 基本フロー")
    @MainActor
    func backToPerformanceList_success() async {
        let app = AppDependencies.make(for: .test)
        let useCase = app.performanceDetailScreenUseCase

        // ── 前提: なし ──

        // ── 操作: 戻る操作（手順1） ──
        let effects = await (await useCase.backToPerformanceList()).collectAll()

        // ── 検証 ──
        #expect(effects == [.screen(.navigateToPerformanceList)], "手順2: 成績一覧画面へ遷移すること")
    }
}
