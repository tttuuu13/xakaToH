//
//  EditableTextQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableTextQuestionModel: EditableQuestionProtocol {
    let id: UUID = UUID()
    var question: String = ""
    
    func createTextQuestion() -> TextQuestionModel {
        TextQuestionModel(question: question)
    }
}
