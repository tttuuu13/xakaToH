//
//  MultipleChoiceQuestionModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//

struct MultipleChoiceQuestionModel: QuestionProtocol {
    let question: String
    let options: [String]
    var answer: Int?
    var grade: Int?
}
