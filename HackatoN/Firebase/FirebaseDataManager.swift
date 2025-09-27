//
//  FirebaseDataManager.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseDataManager {
    private let db = Firestore.firestore()
    
    func sendCreatedExamToFirebase(exam: ExamModel) async throws {
        let quizData: [String: Any] = [
            "id": exam.id.uuidString,
            "name": exam.name,
            "startTime": Timestamp(date: exam.startTime),
            "status": exam.status.rawValue,
            "durationSec": 3600 // 1 час по умолчанию
        ]
        
        let quizRef = db.collection("quizzes").document(exam.id.uuidString)
        
        // Сохраняем основную информацию о квизе
        try await quizRef.setData(quizData)
        
        // Добавляем участников в подколлекцию participants
        for studentUID in exam.studentUIDs {
            let participantData: [String: Any] = [
                "uid": studentUID,
                "joinedAt": Timestamp(date: Date())
            ]
            try await quizRef.collection("participants").document(studentUID).setData(participantData)
        }
        
        // Добавляем вопросы в подколлекцию questions
        for section in exam.sections {
            for question in section.questions {
                var questionData: [String: Any] = [
                    "id": question.id.uuidString,
                    "question": question.question,
                    "sectionName": section.name
                ]
                
                if let mcQuestion = question as? MCQuestionModel {
                    questionData["type"] = "multiple_choice"
                    questionData["options"] = mcQuestion.options
                } else {
                    questionData["type"] = "text"
                }
                
                try await quizRef.collection("questions").document(question.id.uuidString).setData(questionData)
            }
        }
        
        print("Квиз успешно сохранен в Firebase")
    }
    
    func getExamsForStudent(studentUID: String) async throws -> [ExamModel] {
        // Получаем все квизы где пользователь является участником
        let quizzesSnapshot = try await db.collection("quizzes").getDocuments()
        
        var exams: [ExamModel] = []
        
        for quizDoc in quizzesSnapshot.documents {
            let quizData = quizDoc.data()
            let quizId = quizDoc.documentID
            
            // Проверяем, является ли пользователь участником этого квиза
            let participantDoc = try await db.collection("quizzes").document(quizId)
                .collection("participants").document(studentUID).getDocument()
            
            guard participantDoc.exists else { continue }
            
            guard let id = quizData["id"] as? String,
                  let name = quizData["name"] as? String,
                  let startTimeTimestamp = quizData["startTime"] as? Timestamp,
                  let statusString = quizData["status"] as? String,
                  let status = ExamStatus(rawValue: statusString) else {
                continue
            }
            
            // Получаем вопросы из подколлекции
            let questionsSnapshot = try await db.collection("quizzes").document(quizId)
                .collection("questions").getDocuments()
            
            // Группируем вопросы по секциям
            var sectionMap: [String: [any QuestionProtocol]] = [:]
            
            for questionDoc in questionsSnapshot.documents {
                let questionData = questionDoc.data()
                
                guard let questionText = questionData["question"] as? String,
                      let type = questionData["type"] as? String,
                      let sectionName = questionData["sectionName"] as? String else {
                    continue
                }
                
                let question: any QuestionProtocol
                
                if type == "multiple_choice" {
                    guard let options = questionData["options"] as? [String] else { continue }
                    question = MCQuestionModel(question: questionText, options: options)
                } else {
                    question = TextQuestionModel(question: questionText)
                }
                
                if sectionMap[sectionName] == nil {
                    sectionMap[sectionName] = []
                }
                sectionMap[sectionName]?.append(question)
            }
            
            // Создаем секции из сгруппированных вопросов
            let sections = sectionMap.map { (sectionName, questions) in
                ExamSectionModel(name: sectionName, questions: questions)
            }
            
            let exam = ExamModel(
                name: name,
                startTime: startTimeTimestamp.dateValue(),
                status: status,
                sections: sections,
                studentUIDs: [studentUID] // Для совместимости
            )
            
            exams.append(exam)
        }
        
        return exams
    }
    
    func getAllExams() async throws -> [ExamModel] {
        let snapshot = try await db.collection("exams").getDocuments()
        
        var exams: [ExamModel] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            guard let id = data["id"] as? String,
                  let examId = UUID(uuidString: id),
                  let name = data["name"] as? String,
                  let startTimeTimestamp = data["startTime"] as? Timestamp,
                  let statusString = data["status"] as? String,
                  let status = ExamStatus(rawValue: statusString),
                  let studentUIDs = data["studentUIDs"] as? [String],
                  let sectionsData = data["sections"] as? [[String: Any]] else {
                continue
            }
            
            let sections = sectionsData.compactMap { sectionData -> ExamSectionModel? in
                guard let sectionId = sectionData["id"] as? String,
                      let sectionUUID = UUID(uuidString: sectionId),
                      let sectionName = sectionData["name"] as? String,
                      let questionsData = sectionData["questions"] as? [[String: Any]] else {
                    return nil
                }
                
                let questions = questionsData.compactMap { questionData -> (any QuestionProtocol)? in
                    guard let questionId = questionData["id"] as? String,
                          let questionUUID = UUID(uuidString: questionId),
                          let questionText = questionData["question"] as? String,
                          let type = questionData["type"] as? String else {
                        return nil
                    }
                    
                    if type == "multiple_choice" {
                        guard let options = questionData["options"] as? [String] else {
                            return nil
                        }
                        
                        let answer = questionData["answer"] as? Int
                        let grade = questionData["grade"] as? Int
                        
                        return MCQuestionModel(question: questionText, options: options, answer: answer, grade: grade)
                    } else {
                        let answer = questionData["answer"] as? String
                        let grade = questionData["grade"] as? Int
                        
                        return TextQuestionModel(question: questionText, answer: answer, grade: grade)
                    }
                }
                
                return ExamSectionModel(name: sectionName, questions: questions)
            }
            
            let exam = ExamModel(
                name: name,
                startTime: startTimeTimestamp.dateValue(),
                status: status,
                sections: sections,
                studentUIDs: studentUIDs
            )
            
            exams.append(exam)
        }
        
        return exams
    }
}
