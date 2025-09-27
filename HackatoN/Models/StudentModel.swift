//
//  StudentModel.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import Foundation

struct StudentModel {
    let id: UUID
    let uid: String
    let name: String
    let email: String
    var isSelected: Bool = false
    
    init(id: UUID = UUID(), uid: String, name: String, email: String, isSelected: Bool = false) {
        self.id = id
        self.uid = uid
        self.name = name
        self.email = email
        self.isSelected = isSelected
    }
}
