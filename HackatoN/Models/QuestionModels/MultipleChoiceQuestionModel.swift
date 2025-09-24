//
//  MultipleChoiceQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

struct MultipleChoiceQuestionModel: QuestionProtocol {
    let id: UUID = UUID()
    let question: String
    let options: [String]
    var answer: Int?
    var grade: Int?
}
