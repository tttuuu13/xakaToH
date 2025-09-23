//
//  QuestionListModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

struct QuestionListModel {
    let name: String
    let startTime: Date
    var status: ExamStatus
    var questions: [QuestionProtocol]
}
