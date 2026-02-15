// このファイルは自動生成されています

import Foundation

@MainActor
public protocol ProblemListScreenUseCaseProtocol: Sendable {
    func loadHistoryList() async -> AsyncStream<ProblemListScreenViewEffect>
    func openHistoryDetail(sessionID: UUID) async -> AsyncStream<ProblemListScreenViewEffect>
}

public struct UnimplementedProblemListScreenUseCase: ProblemListScreenUseCaseProtocol {
    public nonisolated init() {}

    public func loadHistoryList() async -> AsyncStream<ProblemListScreenViewEffect> {
        fatalError("loadHistoryList is not implemented")
    }

    public func openHistoryDetail(sessionID: UUID) async -> AsyncStream<ProblemListScreenViewEffect> {
        fatalError("openHistoryDetail is not implemented")
    }
}

@MainActor
public struct ProblemListScreenUseCase: ProblemListScreenUseCaseProtocol {
    private let studySessionRepository: any StudySessionRepository

    public init(studySessionRepository: any StudySessionRepository) {
        self.studySessionRepository = studySessionRepository
    }

    public func loadHistoryList() async -> AsyncStream<ProblemListScreenViewEffect> {
        EffectStream.make { yield in
            yield(.showLoading)
            defer { yield(.hideLoading) }

            do {
                // 手順3: 学習履歴一覧を読み込む
                let sessions = try await studySessionRepository.fetchAll()
                let sorted = sessions.sorted { $0.startedAt > $1.startedAt }
                if sorted.isEmpty {
                    yield(.showEmptyState)
                } else {
                    // 手順5: 履歴概要の一覧を表示する
                    yield(.showHistoryList(sorted))
                }
            } catch {
                yield(.showError(.loadFailed))
            }
        }
    }

    public func openHistoryDetail(sessionID: UUID) async -> AsyncStream<ProblemListScreenViewEffect> {
        EffectStream.make { yield in
            // 手順2: 選択した学習回IDの成績詳細画面へ遷移する
            yield(.navigateToStudyResult(sessionID))
        }
    }
}

public enum ProblemListScreenError: Error, Equatable, Sendable {
    case loadFailed
}
