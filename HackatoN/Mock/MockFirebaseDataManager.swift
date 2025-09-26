//
//  MockFirebaseDataManager.swift
//  HackatoN
//
//  Created by Nick on 26.09.2025.
//

import Foundation

class MockFirebaseDataManager {
    func sendCreatedExamToFirebase(exam: ExamModel) async throws {
        print("exam sent to firebase")
        //throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    func getExamsFromFirebase() async throws -> [ExamModel] {
        sleep(1)
        return MockExamProvider.provide()
        //throw NSError(domain: "", code: 0, userInfo: nil)
    }
}
