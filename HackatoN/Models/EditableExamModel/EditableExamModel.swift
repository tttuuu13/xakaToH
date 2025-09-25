//
//  EditableExamModel.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

struct EditableExamModel {
    var name: String = ""
    var startTime: Date = Date.now
    var sections: [EditableExamSectionModel] = []
}
