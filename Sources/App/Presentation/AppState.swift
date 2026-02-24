import SwiftUI
import Observation

public enum AppTab: Hashable {
    case wordChallengeStart
    case performanceList
}

public enum Screen: Hashable {
    case studySession(sessionID: UUID)
    case performanceDetail(sessionID: UUID)
}

public protocol AppEffectConvertible: Sendable {
    func asAppEffect() -> AppEffect
}

public enum AppEffect {
    case wordChallengeStart(WordChallengeStartScreenEffect)
    case studySession(StudySessionScreenEffect)
    case performanceList(PerformanceListScreenEffect)
    case performanceDetail(PerformanceDetailScreenEffect)
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
            case .navigateToStudySession(let sessionID):
                selectedTab = .wordChallengeStart
                navigationPath.removeLast(navigationPath.count)
                navigationPath.append(Screen.studySession(sessionID: sessionID))
            default:
                break
            }
        case .studySession(let effect):
            switch effect {
            case .navigateToPerformanceList:
                selectedTab = .performanceList
                navigationPath.removeLast(navigationPath.count)
            default:
                break
            }
        case .performanceList(let effect):
            switch effect {
            case .navigateToPerformanceDetail(let sessionID):
                selectedTab = .performanceList
                navigationPath.removeLast(navigationPath.count)
                navigationPath.append(Screen.performanceDetail(sessionID: sessionID))
            default:
                break
            }
        case .performanceDetail(let effect):
            switch effect {
            case .navigateToPerformanceList:
                selectedTab = .performanceList
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            default:
                break
            }
        }
    }
}
