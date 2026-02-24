import Foundation
import SwiftData

public typealias SwiftDataRepository_WordCard = SwiftDataRepository<WordCardBiMapper>

extension SwiftDataRepository: WordCardRepository where Mapper == WordCardBiMapper {
    public func fetchByGrade(grade: SchoolGrade, count: StudyItemCount) async throws -> [WordCard] {
        do {
            let descriptor = FetchDescriptor<WordCardPersistentModel>()
            let persistents = try context.fetch(descriptor)
            return try persistents
                .filter { $0.gradeRawValue == grade.rawValue }
                .prefix(count.value)
                .map { persistent in
                    do {
                        return try mapper.toDomain(persistent)
                    } catch {
                        throw RepositoryError.conversionFailed(error)
                    }
                }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.innerError(error)
        }
    }

    public func fetchByIDs(ids: [UUID]) async throws -> [WordCard] {
        do {
            let idSet = Set(ids)
            let descriptor = FetchDescriptor<WordCardPersistentModel>()
            let persistents = try context.fetch(descriptor)
            return try persistents.filter { idSet.contains($0.id) }.map { persistent in
                do {
                    return try mapper.toDomain(persistent)
                } catch {
                    throw RepositoryError.conversionFailed(error)
                }
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.innerError(error)
        }
    }
}
