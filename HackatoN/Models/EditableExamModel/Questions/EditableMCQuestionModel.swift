//
//  EditableMCQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableMCQuestionModel: EditableQuestionProtocol {
    var question: String = ""
    var options: [String] = []
}
