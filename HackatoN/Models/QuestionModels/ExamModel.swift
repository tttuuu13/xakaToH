//
//  QuestionListModel.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

struct ExamModel {
    let name: String
    let startTime: Date
    let id: UUID = UUID()
    var status: ExamStatus
    var sections: [ExamSectionModel]
}
