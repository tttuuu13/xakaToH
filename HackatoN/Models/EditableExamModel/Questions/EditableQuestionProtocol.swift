//
//  EditableQuestionProtocol.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

protocol EditableQuestionProtocol {
    var id: UUID { get }
    var question: String { get set }
}
