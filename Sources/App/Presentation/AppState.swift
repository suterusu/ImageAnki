// このファイルは自動生成されています

import Foundation
import Observation
import SwiftUI

public enum AppTab: Hashable {
    case wordChallengeStart
    case problemList
}

public enum Screen: Hashable {
    case studyCard(sessionID: UUID)
    case studyResult(sessionID: UUID)
}

public protocol AppEffectConvertible: Sendable {
    func asAppEffect() -> AppEffect
}

public enum AppEffect: Sendable {
    case wordChallengeStart(WordChallengeStartScreenViewEffect)
    case studyCard(StudyCardScreenViewEffect)
    case studyResult(StudyResultScreenViewEffect)
    case problemList(ProblemListScreenViewEffect)
}

@MainActor
@Observable
public final class AppState {
    public var selectedTab: AppTab = .wordChallengeStart
    public var navigationPath = NavigationPath()

    public init() {}

    public func apply(_ effect: AppEffect) {
        switch effect {
        case .wordChallengeStart(let effect):
            switch effect {
            case .navigateToStudyCard(let sessionID):
                navigationPath.append(Screen.studyCard(sessionID: sessionID))
            default:
                break
            }
        case .studyCard(let effect):
            switch effect {
            case .navigateToStudyResult(let sessionID):
                navigationPath.append(Screen.studyResult(sessionID: sessionID))
            default:
                break
            }
        case .studyResult(let effect):
            switch effect {
            case .navigateToProblemList:
                selectedTab = .problemList
                while !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            case .navigateToStudyCard(let sessionID):
                while !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
                selectedTab = .wordChallengeStart
                navigationPath.append(Screen.studyCard(sessionID: sessionID))
            default:
                break
            }
        case .problemList(let effect):
            switch effect {
            case .navigateToStudyResult(let sessionID):
                navigationPath.append(Screen.studyResult(sessionID: sessionID))
            default:
                break
            }
        }
    }
}
