// LocalExamStateStore.swift
import Foundation

final class LocalExamStateStore {
    private let defaults: UserDefaults
    private let startedPrefix = "exam_startedAt_"
    private let finishedPrefix = "exam_finished_"
    private let answersPrefix = "exam_answers_"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func startedAt(for examId: UUID) -> Date? {
        defaults.object(forKey: startedPrefix + examId.uuidString) as? Date
    }
    
    func markStarted(examId: UUID, date: Date = Date()) {
        print("LocalExamStateStore: помечаем экзамен \(examId) как начатый в \(date)")
        defaults.set(date, forKey: startedPrefix + examId.uuidString)
        // На случай, если ранее был помечен завершенным — снимем флаг
        defaults.removeObject(forKey: finishedPrefix + examId.uuidString)
    }
    
    func isFinished(examId: UUID) -> Bool {
        defaults.bool(forKey: finishedPrefix + examId.uuidString)
    }
    
    func markFinished(examId: UUID) {
        print("LocalExamStateStore: помечаем экзамен \(examId) как завершенный")
        defaults.set(true, forKey: finishedPrefix + examId.uuidString)
    }
    
    // Сохранение ответов
    func saveAnswers(for examId: UUID, answers: [String: Any]) {
        defaults.set(answers, forKey: answersPrefix + examId.uuidString)
    }
    
    func getAnswers(for examId: UUID) -> [String: Any]? {
        return defaults.dictionary(forKey: answersPrefix + examId.uuidString)
    }
    
    func clear(examId: UUID) {
        print("LocalExamStateStore: очищаем данные для экзамена \(examId)")
        defaults.removeObject(forKey: startedPrefix + examId.uuidString)
        defaults.removeObject(forKey: finishedPrefix + examId.uuidString)
        defaults.removeObject(forKey: answersPrefix + examId.uuidString)
    }
}
