import Foundation
import Testing

@testable import App

@Suite
struct ProblemListScreenUseCaseTests {
    // 仕様トレース: ユースケース1 手順3,5
    @Test("ユースケース1: 学習履歴一覧を確認する - 基本フロー")
    @MainActor
    func loadHistoryList_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.problemListScreenUseCase
        let sessionRepository = app.studySessionRepositoryForTest

        // ── 前提: 履歴が1件存在する ──
        let session = try TestFactory.session(requestedCount: 1)
        try await sessionRepository.save(session: session)

        // ── 操作: 成績一覧タブを開く（手順1） ──
        let effects = await (await useCase.loadHistoryList()).collectAll()

        // ── 検証 ──
        #expect(effects.first == .showLoading, "手順2: ローディング状態を表示すること")
        #expect(effects.contains { effect in
            if case .showHistoryList = effect { return true }
            return false
        }, "手順5: 履歴概要の一覧を表示すること")
    }

    // 仕様トレース: ユースケース2 手順2
    @Test("ユースケース2: 学習履歴の詳細を表示する - 基本フロー")
    @MainActor
    func openHistoryDetail_success() async throws {
        let app = AppDependencies.make(for: .test)
        let useCase = app.problemListScreenUseCase
        let sessionID = UUID()

        // ── 前提: なし ──

        // ── 操作: 学習履歴セルをタップする（手順1） ──
        let effects = await (await useCase.openHistoryDetail(sessionID: sessionID)).collectAll()

        // ── 検証 ──
        #expect(effects == [.navigateToStudyResult(sessionID)], "手順2: 成績詳細画面へ遷移すること")
    }
}
