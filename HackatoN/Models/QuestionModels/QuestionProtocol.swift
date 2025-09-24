//
//  QuestionProtocol.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//
import Foundation

protocol QuestionProtocol {
    var id: UUID { get }
    var question: String { get }
    var grade: Int? { get set }
}
