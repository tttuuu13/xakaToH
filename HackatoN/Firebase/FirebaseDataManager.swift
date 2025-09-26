import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseDataManager {
    
    private let db: Firestore
    private let auth: Auth
    private let collectionName: String = "quizzes"
    
    init(db: Firestore = Firestore.firestore(), auth: Auth = Auth.auth()) {
        self.db = db
        self.auth = auth
    }
    
    enum DataManagerError: LocalizedError {
        case userNotAuthenticated
        case emptySnapshot
        
        var errorDescription: String? {
            switch self {
            case .userNotAuthenticated:
                return "Пользователь не авторизован"
            case .emptySnapshot:
                return "Пустой ответ от Firestore"
            }
        }
    }
    
    // Загрузка экзаменов из Firestore (только созданных текущим пользователем)
    func getExamsFromFirebase() async throws -> [ExamModel] {
        guard let uid = auth.currentUser?.uid else {
            throw DataManagerError.userNotAuthenticated
        }
        
        let snapshot: QuerySnapshot = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<QuerySnapshot, Error>) in
            db.collection(collectionName)
                .getDocuments { snapshot, error in  // Загружаем ВСЕ экзамены
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let snapshot = snapshot {
                        continuation.resume(returning: snapshot)
                    } else {
                        continuation.resume(throwing: DataManagerError.emptySnapshot)
                    }
                }
        }
        
        var exams: [ExamModel] = []
        for document in snapshot.documents {
            let data = document.data()
            
            let name = data["name"] as? String ?? ""
            
            let startTime: Date = {
                if let ts = data["startTime"] as? Timestamp {
                    return ts.dateValue()
                } else if let date = data["startTime"] as? Date {
                    return date
                } else {
                    return Date()
                }
            }()
            
            let statusString = data["status"] as? String ?? ExamStatus.scheduled.rawValue
            let status = ExamStatus(rawValue: statusString) ?? .scheduled
            
            let sectionsArray = data["sections"] as? [[String: Any]] ?? []
            var sections: [ExamSectionModel] = []
            
            for sectionDict in sectionsArray {
                let sectionName = sectionDict["name"] as? String ?? ""
                let questionsArray = sectionDict["questions"] as? [[String: Any]] ?? []
                var questions: [QuestionProtocol] = []
                
                for qDict in questionsArray {
                    let type = qDict["type"] as? String ?? "text"
                    let qText = qDict["question"] as? String ?? ""
                    
                    let grade: Int? = {
                        if let n = qDict["grade"] as? NSNumber {
                            return n.intValue
                        } else if let i = qDict["grade"] as? Int {
                            return i
                        } else if let d = qDict["grade"] as? Double {
                            return Int(d)
                        } else {
                            return nil
                        }
                    }()
                    
                    switch type {
                    case "mc":
                        let options = qDict["options"] as? [String] ?? []
                        let answer: Int? = {
                            if let n = qDict["answer"] as? NSNumber { return n.intValue }
                            return qDict["answer"] as? Int
                        }()
                        let model = MCQuestionModel(question: qText, options: options, answer: answer, grade: grade)
                        questions.append(model)
                    default:
                        let answer = qDict["answer"] as? String
                        let model = TextQuestionModel(question: qText, answer: answer, grade: grade)
                        questions.append(model)
                    }
                }
                
                sections.append(ExamSectionModel(name: sectionName, questions: questions))
            }
            
            let exam = ExamModel(name: name, startTime: startTime, status: status, sections: sections)
            exams.append(exam)
        }
        
        return exams
    }
    
    // Сохранение экзамена в Firestore
    func sendCreatedExamToFirebase(exam: ExamModel) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw DataManagerError.userNotAuthenticated
        }
        
        var data = examToDictionary(exam, createdBy: uid)
        data["createdAt"] = FieldValue.serverTimestamp()
        
        try await addDocument(collection: collectionName, data: data)
    }
    
    // MARK: - Private
    
    private func addDocument(collection: String, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection(collection).addDocument(data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func examToDictionary(_ exam: ExamModel, createdBy: String) -> [String: Any] {
        let sectionsArray: [[String: Any]] = exam.sections.map { section in
            let questionsArray: [[String: Any]] = section.questions.map { q in
                var base: [String: Any] = [
                    "id": q.id.uuidString,
                    "question": q.question
                ]
                if let grade = q.grade { base["grade"] = grade }
                
                if let text = q as? TextQuestionModel {
                    base["type"] = "text"
                    if let ans = text.answer { base["answer"] = ans }
                } else if let mc = q as? MCQuestionModel {
                    base["type"] = "mc"
                    base["options"] = mc.options
                    if let ans = mc.answer { base["answer"] = ans }
                } else {
                    base["type"] = "unknown"
                }
                return base
            }
            
            return [
                "id": section.id.uuidString,
                "name": section.name,
                "questions": questionsArray
            ]
        }
        
        return [
            "id": exam.id.uuidString,
            "name": exam.name,
            "startTime": exam.startTime,
            "status": exam.status.rawValue,
            "sections": sectionsArray,
            "createdBy": createdBy
        ]
    }
}
