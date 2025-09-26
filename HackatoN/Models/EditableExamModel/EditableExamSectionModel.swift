//
//  EditableSectionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableExamSectionModel {
    let id: UUID = UUID()
    var name: String = ""
    var questions: [EditableQuestionProtocol] = []
    
    func createExamSection() -> ExamSectionModel {
        var realQuestions: [QuestionProtocol] = []
        for question in questions {
            if let textQuestion = question as? EditableTextQuestionModel {
                realQuestions.append(textQuestion.createTextQuestion())
            }
            if let mcQuestion = question as? EditableMCQuestionModel {
                realQuestions.append(mcQuestion.createMCQuestion())
            }
        }
        return ExamSectionModel(name: name, questions: realQuestions)
    }
}
