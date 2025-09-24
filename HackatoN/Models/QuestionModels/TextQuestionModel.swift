//
//  QuestionModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

struct TextQuestionModel: QuestionProtocol {
    let id: UUID = UUID()
    let question: String
    var answer: String?
    var grade: Int?
}
