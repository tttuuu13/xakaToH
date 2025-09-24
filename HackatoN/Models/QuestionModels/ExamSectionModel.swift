//
//  ExamSectionModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct ExamSectionModel {
    let id: UUID = UUID()
    var name: String
    var questions: [QuestionProtocol]
}
