//
//  EditableMCQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableMCQuestionModel: EditableQuestionProtocol {
    let id: UUID = UUID()
    var question: String = ""
    var options: [String] = []
    
    func createMCQuestion() -> MCQuestionModel {
        MCQuestionModel(question: question, options: options)
    }
}
