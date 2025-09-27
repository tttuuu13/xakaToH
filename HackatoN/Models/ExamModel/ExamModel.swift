//
//  QuestionListModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

struct ExamModel {
    let id: UUID = UUID()
    let name: String
    let startTime: Date
    var status: ExamStatus
    var sections: [ExamSectionModel]
    var studentUIDs: [String] = []
}
