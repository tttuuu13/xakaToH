//
//  EditableTextQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableTextQuestionModel: EditableQuestionProtocol {
    let id: UUID
    var question: String
    
    init(question: String = "") {
        self.id = UUID()
        self.question = question
    }
    
    init(id: UUID, question: String) {
        self.id = id
        self.question = question
    }
    
    func createTextQuestion() -> TextQuestionModel {
        TextQuestionModel(question: question)
    }
}
