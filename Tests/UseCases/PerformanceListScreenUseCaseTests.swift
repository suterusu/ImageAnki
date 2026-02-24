import Foundation
import ImageAnki
import Testing

struct PerformanceListScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順2,3,4,5
    @Test("ユースケース1: 学習成績一覧を確認する - 基本フロー")
    @MainActor
    func fetchPerformanceList_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.performanceListScreenUseCase
        let repository = app.studySessionRepositoryForTest

        // ── 前提: 成績対象セッションが存在する ──
        let session = StudySession.test(targetCount: 1, cardIDs: [UUID()])
        try await repository.insert(session)

        // ── 操作: 成績一覧を取得する（手順2） ──
        let effects = await (await useCase.fetchPerformanceList()).collectAll()

        // ── 検証 ──
        #expect(effects.first == .screen(.showLoading), "手順2: showLoadingを返すこと")
        #expect(effects.contains(where: {
            if case .screen(.updateSummaryList) = $0 { return true }
            return false
        }), "手順5: 成績概要リストを表示すること")
    }

    // 仕様トレース: ユースケース2 手順1,2
    @Test("ユースケース2: 学習成績詳細を表示する - 基本フロー")
    @MainActor
    func selectPerformance_success() async {
        let app = AppDependencies.make(for: .test)
        let useCase = app.performanceListScreenUseCase
        let sessionID = UUID()

        // ── 前提: なし ──

        // ── 操作: 成績セル選択（手順1） ──
        let effects = await (await useCase.selectPerformance(sessionID: sessionID)).collectAll()

        // ── 検証 ──
        #expect(effects == [.screen(.navigateToPerformanceDetail(sessionID: sessionID))], "手順2: 成績詳細画面へ遷移すること")
    }
}
